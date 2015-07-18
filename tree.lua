TreeAct = class(TreeAct)

local shapes = {}
local trunks = {}
local bodies = {}

local function static_init()
    local trunk1_size = bs/3
    local trunk1 = {
        -trunk1_size, 0,
        -trunk1_size, -trunk1_size,
        trunk1_size, -trunk1_size,
        trunk1_size, 0
    }

    local trunk2_size = bs/6
    local trunk2 = {
        -trunk2_size, 0,
        -trunk2_size, -trunk2_size,
        trunk2_size, -trunk2_size,
        trunk2_size, 0
    }

    local trunk3_size = bs/8
    local trunk3 = {
        -trunk3_size, 0,
        -trunk3_size, -trunk3_size,
        trunk3_size, -trunk3_size,
        trunk3_size, 0
    }

    trunks = {
        pvx_add_shape(0.4, 0.25, 0.1, trunk1),
        pvx_add_shape(0.4, 0.25, 0.1, trunk2),
        pvx_add_shape(0.4, 0.25, 0.1, trunk3)
    }

    local body1 = {
        -bs*3.2, -trunk1_size,
        0, -bs*7.2,
        bs*3.2, -trunk1_size
    }

    local body2 = {
        -bs*0.9, -trunk2_size,
        0, -bs*2.1,
        bs*0.9, -trunk2_size
    }

    local body3 = {
        -bs*0.3, -trunk3_size,
        0, -bs*1.1,
        bs*0.3, -trunk3_size
    }

    bodies = {
        pvx_add_shape(0.3, 0.95, 0.5, body1),
        pvx_add_shape(0.2, 0.95, 0.4, body2),
        pvx_add_shape(0.2, 0.95, 0.1, body3)
    }
end

Entity.add_static_init_func(static_init)

function TreeAct:init()
    local n = math.random(1, #bodies)
    self.body = bodies[n]
    self.trunk = trunks[n]
end

function TreeAct:calc_bounds(pos)
    return {
        left = pos.x - bs,
        top = pos.y - bs,
        right = pos.x + bs,
        bottom = pos.y + bs
    }
end

function TreeAct:get_size()
    return Vector2(bs * 2, bs * 2)
end

function TreeAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(self.trunk, x, y)
    pvx_draw_shape(self.body, x, y)
end

function TreeAct:is_danceable()
    return true
end

function TreeAct:get_interact_pos()
    return self.entity:get_position() + Vector2(self:get_size().x, 0)
end

function TreeAct:is_blocking(pos)
    local entity_bounds = self.entity:get_bounds()
    return bounds_contains(entity_bounds, pos)
end
