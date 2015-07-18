require "house_world"

HouseAct = class(HouseAct)

local shapes = {}

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
        left_side = pvx_add_shape(1, 0.325, 0.123, left_side_square),
        right_side = pvx_add_shape(1, 0.325, 0.123, right_side_square),
        fill_roof = pvx_add_shape(0.4, 0.3, 0.14, square),
        left_side_roof = pvx_add_shape(0.4, 0.3, 0.14, left_side_roof),
        right_side_roof = pvx_add_shape(0.4, 0.3, 0.14, right_side_roof),
        door = pvx_add_shape(0.1, 0.02, 0.1, square),
        window = pvx_add_shape(0.5, 0.4, 0.9, square)
    }
end

Entity.add_static_init_func(static_init)

function HouseAct:init(block_size)
    assert(block_size ~= nil)
    self.block_size = block_size
    self.blocks = {}
    self.show_inside = false
    local h = block_size.y

    self.placements = {
        door_x = math.random(3, self.block_size.x - 3)
    }

    function get_shape(pos)
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

        if h > 5 and x == 0 and y == math.floor(t + 2) and math.random(0, 1) == 1 then
            return shapes.window
        end

        if h > 6 and x == 0 and y == math.floor(t + 2) - 1 then
            return shapes.window
        end

        if w > 5 and (x == self.placements.door_x + 3 or x == self.placements.door_x - 3) and y == b - 1 and x ~= r - 1 and x ~= l + 1 then
            return shapes.window
        end

        return shapes.wall
    end

    for x = 1, block_size.x do
        for y = 1, block_size.y do
            local block_pos = Vector2(x, y)

            table.insert(self.blocks, {
                shape = get_shape(block_pos),
                position = (block_pos + Vector2(math.floor(-block_size.x/2), -block_size.y)) * bs
            })
        end
    end
end

function HouseAct:calc_bounds(pos)
    local bounds = {}

    for _, block in ipairs(self.blocks) do
        if bounds.left == nil or block.position.x + pos.x < bounds.left then
            bounds.left = block.position.x + pos.x + 1
        end

        if bounds.top == nil or block.position.y + pos.y < bounds.top then
            bounds.top = block.position.y + pos.y + 1
        end

        if bounds.right == nil or block.position.x + pos.x + bs > bounds.right then
            bounds.right = block.position.x + pos.x + bs
        end

        if bounds.bottom == nil or block.position.y + pos.y + bs > bounds.bottom then
            bounds.bottom = block.position.y + pos.y + bs
        end
    end

    bounds.left = bounds.left - 1
    bounds.top = bounds.top - 1
    bounds.right = bounds.right + 1
    bounds.bottom = bounds.bottom + 1
    return bounds
end

function HouseAct:get_size()
    return self.block_size * bs
end

function HouseAct:start()
    local bounds = self.entity:get_bounds()
    local inside_world_offset = Vector2(bounds.left, bounds.top) - Vector2(bs, 0)
    self.inside_world = World(function(size, world) return generate_house_world(inside_world_offset, self.placements, shapes, size, world) end, self.block_size + Vector2(0, -1))
    self.inside_world:start()
end

function HouseAct:tick()
    self.inside_world:tick()
end

function HouseAct:draw()
    if self.show_inside then
        self.inside_world:draw()
    else
        local x, y = self.entity:get_position():unpack()

        for _, block in ipairs(self.blocks) do
            pvx_draw_shape(block.shape, x + block.position.x, y + block.position.y)
        end
    end
end

function HouseAct:left_mouse_clicked(pos)
    self.show_inside = true
end

function HouseAct:right_mouse_clicked(pos)
    self.show_inside = false
end

function HouseAct:get_exits()
    local bounds = self.entity:get_bounds()

    return {
        {
            position = Vector2(bounds.left - bs/2 + self.placements.door_x * bs, bounds.bottom),
            world = self.inside_world
        }
    }
end

function HouseAct:find_free_location()
    local entity_bounds = self.entity:get_bounds()

    while true do
        local pos = Vector2(math.random(entity_bounds.left + bs * 2, entity_bounds.right - bs * 2), math.random(entity_bounds.top + bs * 2, entity_bounds.bottom - bs * 2))
        local blocked = false

        for _, block in ipairs(self.blocks) do
            local bounds = {
                left = block.position.x + entity_bounds.left,
                top = block.position.y + entity_bounds.top,
                right = block.position.x + entity_bounds.left + bs,
                bottom = block.position.y + entity_bounds.top + bs
            }

            if bounds_contains(bounds, pos) then
                blocked = true
            end
        end 

        if blocked == false then
            return pos
        end
    end
end

