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
        fill = pvx_add_shape(0.99, 0.99, 0.94, square),
        left_side = pvx_add_shape(0.95, 0.1, 0, left_side_square),
        right_side = pvx_add_shape(0.95, 0.1, 0, right_side_square),
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

    function get_shape(pos)
        local x = pos.x
        local y = pos.y
        local w = block_size.x
        local h = block_size.y
        local l = math.floor(-w/2)
        local t = -h
        local r = math.floor(w/2)
        local b = 0

        if x == l and y == t then
            return shapes.left_side_roof
        end

        if x == r and y == t then
            return shapes.right_side_roof
        end

        if y == t then
            return shapes.fill_roof
        end

        if x == l then
            return shapes.left_side
        end

        if x == r then
            return shapes.right_side
        end

        if (y == b or y == b - 1) and x == 0 then
            return shapes.door
        end

        if h > 5 and x == 0 and y == math.floor(t + 2) and math.random(0, 1) == 1 then
            return shapes.window
        end

        if h > 6 and x == 0 and y == math.floor(t + 2) - 1 then
            return shapes.window
        end

        if w > 5 and (x == math.floor(l/2) or x == math.floor(r/2)) and x ~= 1 and x ~= -1
            and x + 1 ~= r and x - 1 ~= l and y == b + math.floor(t/2) then
            return shapes.window
        end

        return shapes.fill
    end

    for x = math.floor(-block_size.x/2), math.floor(block_size.x/2) do
        for y = -block_size.y, 0 do
            local block_pos = Vector2(x, y)

            table.insert(self.blocks, {
                shape = get_shape(block_pos),
                position = block_pos * bs
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

    return bounds
end

function HouseAct:get_size()
    return self.block_size * bs
end

function HouseAct:draw(position)
    for _, block in ipairs(self.blocks) do
        pvx_draw_shape(block.shape, position.x + block.position.x, position.y + block.position.y)
    end
end