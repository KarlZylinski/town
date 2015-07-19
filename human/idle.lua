require "human/find_interest_point"

HumanIdleState = class(HumanIdleState)

function HumanIdleState:enter()
end

function HumanIdleState:exit()
end

function HumanIdleState:tick()
    if self.data.restlessness > 0.9 or self.data.tiredness > 0.8 then
        return HumanFindInterestPointState()
    end

    self.data.restlessness = math.max(0, self.data.restlessness + self.data.restlessness_change_speed)
    self.data.tiredness = math.max(0, self.data.tiredness + self.data.tiring_speed * 0.5)

    return self
end
