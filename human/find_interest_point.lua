require "human/process_waypoints"
require "human/dancing"

HumanFindInterestPointState = class(HumanFindInterestPointState)

function HumanFindInterestPointState:enter()
end

function HumanFindInterestPointState:exit()
end

function HumanFindInterestPointState:tick()
    local w = self.data.entity.world
    local exits = w:get_exits()

--function find_waypoints(from_world, to_entity, move_complete)
    local function find_nearest_danceable()
        local entity_pos = self.data.entity:get_position()
        local nearest_danceable = nil
        local dist_sq = 10000000000000

        for i, other_entity in ipairs(main_world.entities) do
            if other_entity:is_danceable() and other_entity ~= self.data.entity then
                local len = (other_entity:get_position() - entity_pos):len()

                if len < dist_sq then
                    nearest_danceable = other_entity
                    dist_sq = len
                end
            end
        end

        return nearest_danceable
    end

    --[[if self.data.tiredness > 0.8 then
        local nearest_danceable = find_nearest_danceable()

        if nearest_danceable == nil then
            return self
        end

        local waypoints = find_waypoints(w, nearest_danceable)

        return HumanProcessWaypointsState(waypoints, function()
            return HumanDancingState(nearest_danceable)
        end)
    end--]]

    if self.data.restlessness > 0.9 then
        local nearest_danceable = find_nearest_danceable()

        if nearest_danceable == nil then
            return self
        end

        local waypoints = find_waypoints(w, nearest_danceable)

        return HumanProcessWaypointsState(waypoints, function()
            return HumanDancingState(nearest_danceable)
        end)
    end

    return self
end
