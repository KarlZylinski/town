require "human/idle"

HumanAct = class(HumanAct)

local bodies = {}
local heads = {}
local left_arms = {}
local right_arms = {}

local function static_init()
    local bw, bh = bs/4, bs

    local body = {
        0, 0,
        -bw, 0,
        -bw, -bh,
        bw, -bh,
        bw, 0
    }

    local aw = bs/8
    local al = bs / 1.5

    local left_arm = {
        -bw + aw, -bh,
        -bw , -bh + al,
        -bw - aw, -bh + al - 4,
        -bw, -bh
    }

    local right_arm = {
        bw - aw, -bh,
        bw , -bh + al,
        bw + aw, -bh + al - 4,
        bw, -bh
    }


    local ro = 5
    local rxo = 2
    local ral = bs / 2

    local left_arm_raised = {
        -rxo -bw + aw, -bh + ro,
        -rxo -bw , -bh - ral + ro,
        -rxo -bw - aw, -bh - ral - 4 + ro,
        -rxo -bw, -bh + ro
    }

    local right_arm_raised = {
        rxo + bw - aw, -bh + ro,
        rxo + bw , -bh - ral + ro,
        rxo + bw + aw, -bh - ral - 4 + ro,
        rxo + bw, -bh + ro
    }

    local hs = bs/3-1
    local hyo = 4

    --[[local head = {
        0, -bh + hyo,
        -hs, -bh - hs + hyo,
        0, -bh - hs * 2 + hyo,
        hs, -bh - hs + hyo
    }]]

    local head = {
        -hs/2, -bh,
        -hs/2, -bh - hs,
        hs/2, -bh - hs,
        hs/2, -bh
    }

    bodies = {
        pvx_add_shape(0.9, 0.25, 0, body),
        pvx_add_shape(0.7, 0.95, 0, body),
        pvx_add_shape(0.1, 0.6, 0.9, body),
        pvx_add_shape(0.8, 0.8, 0.9, body)
    }

    heads = {
        pvx_add_shape(0.9, 0.25, 0.1, head),
        pvx_add_shape(0.15, 0.15, 0.4, head),
        pvx_add_shape(0.8, 0.3, 0.01, head)
    }

    left_arms = {
        pvx_add_shape(0.9, 0, 0, left_arm),
        pvx_add_shape(0.0, 0.9, 0, left_arm),
        pvx_add_shape(0.0, 0, 0.9, left_arm)
    }

    right_arms = {
        pvx_add_shape(0.9, 0, 0, right_arm),
        pvx_add_shape(0.0, 0.9, 0, right_arm),
        pvx_add_shape(0.0, 0, 0.9, right_arm)
    }

    left_arms_raised = {
        pvx_add_shape(0.9, 0, 0, left_arm_raised),
        pvx_add_shape(0.0, 0.9, 0, left_arm_raised),
        pvx_add_shape(0.0, 0, 0.9, left_arm_raised)
    }

    right_arms_raised = {
        pvx_add_shape(0.9, 0, 0, right_arm_raised),
        pvx_add_shape(0.0, 0.9, 0, right_arm_raised),
        pvx_add_shape(0.0, 0, 0.9, right_arm_raised)
    }
end

Entity.add_static_init_func(static_init)

function HumanAct:init(home)
    self.home = home
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
    min_restlessness_reduce_speed = 0.0001,
    max_restlessness_reduce_speed = 0.01,
    min_restlessness_change_speed = 0.001,
    max_restlessness_change_speed = 0.01,
    min_speed = 0.4,
    max_speed = 1.4,
    max_tiring_speed = 0.01,
    min_tiring_speed = 0.001
}

local function get_gen_prop(prop)
    return math.random(generation_properties["min_" .. prop], generation_properties["max_" .. prop])
end

function HumanAct:start()
    self.body = bodies[math.random(1, #bodies)]
    self.head = heads[math.random(1, #heads)]
    self.left_arm = left_arms[math.random(1, #left_arms)]
    self.right_arm = right_arms[math.random(1, #right_arms)]
    self.left_arm_raised = left_arms_raised[math.random(1, #left_arms)]
    self.right_arm_raised = right_arms_raised[math.random(1, #right_arms)]
    self.arms_raised = false

    self.data = {
        entity = self.entity,
        restlessness = math.random(0, 1),
        tiredness = math.random(0, 1),
        restlessness_change_speed = get_gen_prop("restlessness_change_speed"),
        restlessness_reduce_speed = get_gen_prop("restlessness_reduce_speed"),
        tiring_speed = get_gen_prop("tiring_speed"),
        speed = get_gen_prop("speed")
    }

   enter_state(self.state, self.data)
end

function HumanAct:set_arms_raised(raised)
    self.arms_raised = raised
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

    if self.arms_raised then
        pvx_draw_shape(self.left_arm_raised, x, y)
        pvx_draw_shape(self.right_arm_raised, x, y)
    else
        pvx_draw_shape(self.left_arm, x, y)
        pvx_draw_shape(self.right_arm, x, y)
    end
end

