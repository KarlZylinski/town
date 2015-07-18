HumanDancingState = class(HumanDancingState)

function HumanDancingState:init(target)
    assert(target ~= nil)
    self.target = target
    self.angle = 0
    self.start_time = os.clock()
end

function HumanDancingState:enter()
    self.radius = (self.target:get_position() - self.data.entity:get_position()):len()
end

function HumanDancingState:exit()
end

function HumanDancingState:tick()
    self.angle = self.angle + self.data.speed * 0.01
    self.start_time = self.start_time + 0.1
    local pos = self.target:get_position()
    local x = math.cos(self.angle) * self.radius + pos.x
    local y = math.sin(self.angle) * self.radius + pos.y + math.cos(self.start_time)
    self.data.entity:set_position(Vector2(x, y))

    if self.data.restlessness < 0.2 then
        --return HumanIdleState()
    end

    self.data.restlessness = math.max(0, self.data.restlessness - self.data.restlessness_change_speed)
    return self
end
