HumanPathMovingState = class(HumanPathMovingState)

function HumanPathMovingState:init(path, set_proximity, point_reached)
    self.path = path
    self.set_proximity = set_proximity
    self.point_reached = point_reached
    self.current_node_idx = 1
end

function HumanPathMovingState:enter()
end

function HumanPathMovingState:exit()
end

function HumanPathMovingState:tick()
    local current_node = self.path[self.current_node_idx] 
    local e = self.data.entity
    
    if current_node == nil then
        return self.point_reached()
    end

    local current_pos = e:get_position()
    local pos_to_point = current_node.position - current_pos
    local len_to_point = pos_to_point:len()

    if self.set_proximity ~= nil and self.current_node_idx == #self.path and len_to_point < bs * 3 then
        self.set_proximity(e)
    end

    if len_to_point < 1 then
        self.current_node_idx = self.current_node_idx + 1
    end

    local direction = pos_to_point:normalized()
    e:set_move_direction(direction)
    self.data.restlessness = math.max(0, self.data.restlessness - self.data.restlessness_change_speed)
    return self
end
