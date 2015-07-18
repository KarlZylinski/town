require "human/find_interest_point"

HumanIdleState = class(HumanIdleState)

function HumanIdleState:enter()
end

function HumanIdleState:exit()
end

function HumanIdleState:tick()
    if self.data.restlessness > 0.2 then
        return HumanFindInterestPointState()
    end

    self.data.restlessness = math.max(0, self.data.restlessness + 0.001)

    return self
end
