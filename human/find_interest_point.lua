require "human/moving_to_door"

HumanFindInterestPointState = class(HumanFindInterestPointState)

function HumanFindInterestPointState:enter()
end

function HumanFindInterestPointState:exit()
end

function HumanFindInterestPointState:tick()
    local w = self.data.entity.world
    local exits = w:get_exits()

    if #exits > 0 then
        return HumanMovingToDoorState(exits[math.random(1, #exits)])
    end

    if self.data.restlessness < 0.2 then
        return HumanIdleState()
    end

    return self
end
