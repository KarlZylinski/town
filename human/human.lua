require "human/idle"

HumanAct = class(HumanAct)

local shapes = {}

local function static_init()
    local body = {
        0, 0,
        -bs/4, 0,
        -bs/4, -bs,
        bs/4, -bs,
        bs/4, 0
    }

    shapes = {
        body = pvx_add_shape(1, 1, 0, body)
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

function HumanAct:start()
    self.data = {
        entity = self.entity,
        restlessness = 1
    }

   enter_state(self.state, self.data)
end

function HumanAct:tick()
    self.state = tick_state(self.state, self.data)
end

function HumanAct:draw()
    local x, y = self.entity:get_position():unpack()
    pvx_draw_shape(shapes.body, x, y)
end

