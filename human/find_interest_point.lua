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
        local exit = exits[math.random(1, #exits)]
        local path = w:find_path(self.data.entity:get_position(), exit.position)
        
        if path ~= nil then
            return HumanMovingToDoorState(path, exit.world, exit.set_human_near_exit)
        end
    end

    if self.data.restlessness < 0.2 then
        return HumanIdleState()
    end

    return self
end
