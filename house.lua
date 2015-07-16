House = class(House)

local shapes = {}

function House.static_init()
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

function House:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.blocks = {}

    function get_shape(x, y)
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

    for i = math.floor(-w/2), math.floor(w/2) do
        for j = -h, 0 do
            table.insert(self.blocks, {
                shape = get_shape(i, j),
                x = i * bs,
                y = j * bs
            })
        end
    end

    self:calc_bounds()
end

function House:calc_bounds()
    self.bounds = {}

    for _, block in ipairs(self.blocks) do
        if self.bounds.left == nil or block.x + self.x < self.bounds.left then
            self.bounds.left = block.x + self.x
        end

        if self.bounds.top == nil or block.y + self.y < self.bounds.top then
            self.bounds.top = block.y + self.y
        end

        if self.bounds.right == nil or block.x + self.x + bs > self.bounds.right then
            self.bounds.right = block.x + self.x + bs
        end

        if self.bounds.bottom == nil or block.y + self.y + bs > self.bounds.bottom then
            self.bounds.bottom = block.y + self.y + bs
        end
    end
end

function House:art()
    return house_ascii
end

function House:position()
    return self.x, self.y
end

function House:size()
    return self.w * bs, self.h * bs
end

function House:intersects(ob)
    if other.bounds == nil then
        return false
    end

    return bounds_intersect(self.bounds, other.bounds)
end

function House:set_position(x, y)
    self.x = x
    self.y = y
    self:calc_bounds()
end

function House:draw()
    for _, block in ipairs(self.blocks) do
        pvx_draw_shape(block.shape, self.x + block.x, self.y + block.y)
    end
end