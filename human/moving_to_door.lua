HumanMovingToDoorState = class(HumanMovingToDoorState)

function HumanMovingToDoorState:init(door)
    self.door = door
end

function HumanMovingToDoorState:enter()
end

function HumanMovingToDoorState:exit()
end

function HumanMovingToDoorState:tick()
    local e = self.data.entity
    local current_pos = e:get_position()
    local pos_to_point = self.door.position - current_pos

    if pos_to_point:len() < 1 then
        move_to_world(e, self.door.world)
        return HumanIdleState()
    end

    local direction = pos_to_point:normalized()
    local distance_to_move = direction
    e:set_position(current_pos + distance_to_move)
    self.data.restlessness = math.max(0, self.data.restlessness - distance_to_move:len() * 0.01)
    return self
end
