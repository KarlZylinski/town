FloorAct = class(FloorAct)

function FloorAct:init(shape, size)
    assert(shape ~= nil)
    assert(size ~= nil)
    self.shape = shape
    self.size = size
end

function FloorAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + self.size.x * bs,
        bottom = pos.y + self.size.y * bs
    }
end

function FloorAct:get_size()
    return self.size
end

function FloorAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(self.shape, x, y)
end
