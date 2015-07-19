HumanPartyState = class(HumanPartyState)

function HumanPartyState:init()
    self.start_time = os.clock()
    self.jump_height = math.random(bs/2, bs/6)
end

function HumanPartyState:enter()
    self.pos = self.data.entity:get_position()
    self.data.entity.act:set_is_partying(true)
end

function HumanPartyState:exit()
    self.data.entity.act:set_is_partying(false)
end

function HumanPartyState:tick()
    if self.data.tiredness > 0.9 then
        return HumanIdleState()
    end

    self.start_time = self.start_time + self.data.speed * 0.1
    local y_offset = -math.abs(math.cos(self.start_time) * self.jump_height)
    self.data.entity:set_position(self.pos + Vector2(0, y_offset))
    self.data.restlessness = math.max(0, self.data.restlessness - self.data.restlessness_change_speed)
    self.data.partyneed = math.max(0, self.data.partyneed - self.data.partyneed_speed)
    self.data.tiredness = math.max(0, self.data.tiredness + self.data.tiring_speed * 0.7)
    return self
end
