WallAct = class(WallAct)

function WallAct:init(shape)
    assert(shape ~= nil)
    self.shape = shape
end

function WallAct:calc_bounds(pos)
    return {
        left = pos.x,
        top = pos.y,
        right = pos.x + bs,
        bottom = pos.y + bs
    }
end

function WallAct:get_size()
    return Vector2(bs, bs)
end

function WallAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(self.shape, x, y)
end
