require "house_world"

HouseAct = class(HouseAct)

local shapes = {}
local bar_shapes = {}

local function static_init()
    local square = {
        0, 0,
        bs, 0,
        bs, bs,
        0, bs
    }

    local left_side_square = {
        bs - bs/4, 0,
        bs, 0,
        bs, bs,
        bs - bs/4, bs
    }

    local right_side_square = {
        0, 0,
        bs/4, 0,
        bs/4, bs,
        0, bs
    }

    local left_side_roof = {
        0, bs,
        bs, bs,
        bs, 0
    }

    local right_side_roof = {
        bs, bs,
        0, bs,
        0, 0
    }

    shapes = {
        wall = pvx_add_shape(0.99, 0.99, 0.94, square),
        inside_wall = pvx_add_shape(0.8, 0.8, 0.8, square),
        left_side = pvx_add_shape(1, 0.325, 0.123, left_side_square),
        right_side = pvx_add_shape(1, 0.325, 0.123, right_side_square),
        fill_roof = pvx_add_shape(0.4, 0.3, 0.14, square),
        left_side_roof = pvx_add_shape(0.4, 0.3, 0.14, left_side_roof),
        right_side_roof = pvx_add_shape(0.4, 0.3, 0.14, right_side_roof),
        door = pvx_add_shape(0.3, 0.2, 0.1, square),
        window = pvx_add_shape(0.6, 0.6, 0.9, square)
    }

    bar_shapes = {
        wall = pvx_add_shape(0.7, 0.3, 0.32, square),
        inside_wall = pvx_add_shape(0.7, 0.5, 0.32, square),
        left_side = pvx_add_shape(0.99, 0.99, 0.94, left_side_square),
        right_side = pvx_add_shape(0.99, 0.99, 0.94, right_side_square),
        fill_roof = pvx_add_shape(0.12, 0.2, 0.14, square),
        left_side_roof = pvx_add_shape(0.12, 0.2, 0.14, left_side_roof),
        right_side_roof = pvx_add_shape(0.12, 0.2, 0.14, right_side_roof),
        door = pvx_add_shape(0.92, 0.25, 0.1, square),
        window = pvx_add_shape(0.6, 0.6, 0.9, square)
    }
end

Entity.add_static_init_func(static_init)

function HouseAct:init(block_size, is_bar)
    assert(block_size ~= nil)
    self.is_bar = is_bar
    self.block_size = block_size
    self.blocks = {}
    self.show_inside = false
    local h = block_size.y

    self.placements = {
        door_x = math.random(3, self.block_size.x - 3),
        windows_x = {}
    }

    for i = 3, self.block_size.x - 3 do
        local try_place = math.random(0, 2) == 2

        if try_place and i ~= self.placements.door_x and i ~= self.placements.door_x - 1 and i ~= self.placements.door_x + 1 then
            local too_close = false

            for _, x in ipairs(self.placements.windows_x) do
                if x == i or x - 1 == i or x + 1 == i then
                    too_close = true
                    break
                end
            end

            if not too_close then
                table.insert(self.placements.windows_x, i)
            end
        end
    end

    function get_shape(shapes, pos)
        local x = pos.x
        local y = pos.y
        local w = block_size.x
        local l = 1
        local t = 1
        local r = block_size.x
        local b = block_size.y

        if x == l and y == t then
            return shapes.left_side_roof
        end

        if x == r and y == t then
            return shapes.right_side_roof
        end

        if y == t then
            return shapes.fill_roof
        end

        if y < b - 2 then
            return shapes.fill_roof
        end

        if x == l then
            return shapes.left_side
        end

        if x == r then
            return shapes.right_side
        end

        if (y == b or y == b - 1) and x == self.placements.door_x then
            return shapes.door
        end

        if y == b - 1 then
            for i, window_x in ipairs(self.placements.windows_x) do
                if x == window_x then
                    return shapes.window
                end
            end
        end

        return shapes.wall
    end

    for x = 1, block_size.x do
        for y = 1, block_size.y do
            local block_pos = Vector2(x, y)

            table.insert(self.blocks, {
                shape = get_shape(self:get_shapes(), block_pos),
                position = (block_pos + Vector2(math.floor(-block_size.x/2), -block_size.y)) * bs
            })
        end
    end
end

function HouseAct:calc_bounds(pos)
    local bounds = {}

    for _, block in ipairs(self.blocks) do
        if bounds.left == nil or block.position.x + pos.x < bounds.left then
            bounds.left = block.position.x + pos.x
        end

        if bounds.top == nil or block.position.y + pos.y < bounds.top then
            bounds.top = block.position.y + pos.y
        end

        if bounds.right == nil or block.position.x + pos.x + bs > bounds.right then
            bounds.right = block.position.x + pos.x + bs
        end

        if bounds.bottom == nil or block.position.y + pos.y + bs > bounds.bottom then
            bounds.bottom = block.position.y + pos.y + bs
        end
    end

    bounds.left = bounds.left
    bounds.top = bounds.top
    bounds.right = bounds.right
    bounds.bottom = bounds.bottom
    return bounds
end

function HouseAct:get_size()
    return self.block_size * bs
end

function HouseAct:start()
    local bounds = self.entity:get_bounds()
    local inside_world_offset = Vector2(bounds.left, bounds.top) - Vector2(bs, 0)
    self.inside_world = World(function(size, world) return generate_house_world(inside_world_offset, self.placements, self:get_shapes(), self.entity.world, self, size, world) end, self.block_size + Vector2(0, -1))
    self.inside_world:start()
end

function HouseAct:tick()
    self.inside_world:tick()

    if self.human_near ~= nil then
        local exit_pos = self:get_exit_pos()
        local v = exit_pos - self.human_near:get_position()
        v.x = v.x*3
        
        if (v):len() >= bs * 3 then
            self.human_near = nil
        end
    end
end

function HouseAct:get_shapes()
    if self.is_bar then
        return bar_shapes
    end

    return shapes
end

function HouseAct:draw(screen_rect)
    local human_near = self.human_near ~= nil
    local draw_outside = not self.show_inside
    local draw_inside = self.show_inside or human_near

    if draw_inside then
        self.inside_world:draw(screen_rect)
    end

    if draw_outside then
        local x, y = self.entity:get_position():unpack()

        for _, block in ipairs(self.blocks) do
            if block.shape ~= self:get_shapes().door or not human_near then
                pvx_draw_shape(block.shape, x + block.position.x, y + block.position.y)
            end
        end
    end
end

function HouseAct:left_mouse_clicked(pos)
    self.show_inside = true
end

function HouseAct:right_mouse_clicked(pos)
    self.show_inside = false
end

function HouseAct:set_human_near_exit(human)
    self.human_near = human
end

function HouseAct:get_exit_pos()
    local bounds = self.entity:get_bounds()
    return Vector2(bounds.left - bs/2 + self.placements.door_x * bs, bounds.bottom)
end

function HouseAct:get_exits()
    assert(self.inside_world ~= nil)

    return {
        {
            position = self:get_exit_pos(),
            set_human_near_exit = function(entity) self:set_human_near_exit(entity) end,
            world = self.inside_world
        }
    }
end

function HouseAct:find_free_location()
    local entity_bounds = self.entity:get_bounds()

    while true do
        local pos = Vector2(math.random(entity_bounds.left + bs * 2, entity_bounds.right - bs * 2), math.random(entity_bounds.top + bs * 3, entity_bounds.bottom - bs * 2))
        local inside_entity = self.inside_world:get_containing_blocking_entity(pos)

        if inside_entity == nil then
            return pos
        end
    end
end


function HouseAct:find_free_area_along_wall(size, align)
    local entity_bounds = self.entity:get_bounds()
    local min_y = entity_bounds.top + bs * 3
    local max_y = entity_bounds.bottom - bs * 2 - size.y

    local function get_x(left_side)
        if left_side then
            return entity_bounds.left + bs * 2
        end

        return entity_bounds.right - bs * 2 - size.x
    end

    local function get_bounds_and_pos()
        local function calc()
            local x = get_x(math.random(0, 1) == 1)
            local pos = Vector2(x, math.random(min_y, max_y))

            if align then
                pos.y = pos.y - pos.y % bs
            end

            return pos
        end
        
        local exit_pos = self:get_exit_pos()
        local pos
        
        while true do
            pos = calc()
            
            if (exit_pos - pos):len() > bs * 4 then
                break
            end
        end

        local bounds = {
            left = pos.x,
            top = pos.y,
            right = pos.x + size.x,
            bottom = pos.y + size.y
        }
        return bounds, pos
    end

    while true do
        local bounds, pos = get_bounds_and_pos()
        local intersecting_entity = self.inside_world:get_intersecting_entity(bounds)

        if intersecting_entity == nil or not intersecting_entity:is_blocking() then
            return pos
        end
    end
end

function HouseAct:is_blocking(pos)
    local entity_bounds = self.entity:get_bounds()
    return bounds_contains(entity_bounds, pos)
end
