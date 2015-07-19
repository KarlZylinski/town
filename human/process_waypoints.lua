require "human/path_moving"

HumanProcessWaypointsState = class(HumanProcessWaypointsState)

function HumanProcessWaypointsState:init(waypoints, move_complete)
    assert(waypoints ~= nil)
    self.waypoints = waypoints
    self.move_complete = move_complete
end

function HumanProcessWaypointsState:enter()
end

function HumanProcessWaypointsState:exit()
end

function HumanProcessWaypointsState:tick()
    local current_world = self.data.entity.world

    if #self.waypoints == 0 then
        return HumanIdleState()
    end

    local current_waypoint = self.waypoints[1]
    table.remove(self.waypoints, 1)
    assert(current_world == current_waypoint.world)
    local path = current_world:find_path(self.data.entity:get_position(), current_waypoint.position)
    --[[
    function()
            move_to_world(self.data.entity, exit.world)
            return HumanIdleState()
        end
    ]]

    local function get_move_complete_callback()
        if #self.waypoints == 0 then
            if self.move_complete ~= nil then
                return self.move_complete
            else
                return function() return HumanIdleState() end
            end
        end

        return function()
            if current_waypoint.waypoint_reached ~= nil then
                current_waypoint.waypoint_reached(self.data.entity)
            end

            return self
        end
    end

    if path ~= nil then
        return HumanPathMovingState(path, current_waypoint.set_proximity, get_move_complete_callback())
    end

    return self
end
