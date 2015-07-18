require "human/idle"

HumanAct = class(HumanAct)

local bodies = {}
local heads = {}

local function static_init()
    local bw, bh = bs/4, bs

    local body = {
        0, 0,
        -bw, 0,
        -bw, -bh,
        bw, -bh,
        bw, 0
    }

    local hs = bs/4
    local hyo = 4

    local head = {
        0, -bh + hyo,
        -hs, -bh - hs + hyo,
        0, -bh - hs * 2 + hyo,
        hs, -bh - hs + hyo
    }

    bodies = {
        pvx_add_shape(0.9, 0.25, 0, body),
        pvx_add_shape(0.7, 0.95, 0, body),
        pvx_add_shape(0.1, 0.6, 0.9, body),
        pvx_add_shape(0.8, 0.8, 0.9, body)
    }

    heads = {
        pvx_add_shape(0.9, 0.9, 0.8, head),
        pvx_add_shape(0.95, 0.9, 0.6, head),
        pvx_add_shape(0.15, 0.15, 0.4, head),
        pvx_add_shape(0.8, 0.3, 0.01, head)
    }
end

Entity.add_static_init_func(static_init)

function HumanAct:init()
   self.state = HumanIdleState()
end

function HumanAct:get_size()
    return Vector2(bs, bs*2)
end

function HumanAct:calc_bounds(pos)
    return {
        left = -bs/4 + pos.x,
        top = -bs + pos.y,
        right = bs/4 + pos.x,
        bottom = 0 + pos.y
    }
end

local generation_properties = {
    min_restlessness_change_speed = 0.001,
    max_restlessness_change_speed = 0.1,
    min_speed = 0.4,
    max_speed = 1.4
}

local function get_gen_prop(prop)
    return math.random(generation_properties["min_" .. prop], generation_properties["max_" .. prop])
end

function HumanAct:start()
    self.body = bodies[math.random(1, #bodies)]
    self.head = heads[math.random(1, #heads)]

    self.data = {
        entity = self.entity,
        restlessness = math.random(0, 1),
        restlessness_change_speed = get_gen_prop("restlessness_change_speed"),
        speed = get_gen_prop("speed")
    }

   enter_state(self.state, self.data)
end

function HumanAct:get_speed()
    return self.data.speed
end

function HumanAct:tick()
    self.state = tick_state(self.state, self.data)
end

function HumanAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(self.body, x, y)
    pvx_draw_shape(self.head, x, y)
end

