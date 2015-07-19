HumanDancingState = class(HumanDancingState)

function HumanDancingState:init(target)
    assert(target ~= nil)
    self.target = target
    self.angle = 0
    self.start_time = os.clock()
end

function HumanDancingState:enter()
    self.radius = (self.target:get_position() - self.data.entity:get_position()):len()
    self.data.entity.act:set_arms_raised(true)
end

function HumanDancingState:exit()
    self.data.entity.act:set_arms_raised(false)
end

function HumanDancingState:tick()
    if self.data.tiredness > 0.9 then
        return HumanIdleState()
    end

    self.angle = self.angle + self.data.speed * 0.01
    self.start_time = self.start_time + self.data.speed * 0.1
    local pos = self.target:get_position()
    local x = math.cos(self.angle) * self.radius + pos.x
    local y = math.sin(self.angle) * self.radius + pos.y + math.cos(self.start_time) * bs/8
    self.data.entity:set_position(Vector2(x, y))

    if self.data.restlessness < 0.2 then
        return HumanIdleState()
    end

    self.data.restlessness = math.max(0, self.data.restlessness - self.data.restlessness_change_speed)
    self.data.tiredness = math.max(0, self.data.tiredness + self.data.tiring_speed * 0.4)
    return self
end
