HumanMovingToDoorState = class(HumanMovingToDoorState)

function HumanMovingToDoorState:init(path, world, set_human_near_exit)
    self.path = path
    self.world = world
    self.set_human_near_exit = set_human_near_exit
    self.current_node_idx = 1
end

function HumanMovingToDoorState:enter()
end

function HumanMovingToDoorState:exit()
end

function HumanMovingToDoorState:tick()
    local current_node = self.path[self.current_node_idx] 
    local e = self.data.entity
    
    if current_node == nil then
        move_to_world(e, self.world)
        return HumanIdleState()
    end

    local current_pos = e:get_position()
    local pos_to_point = current_node.position - current_pos
    local len_to_point = pos_to_point:len()

    if self.set_human_near_exit ~= nil and self.current_node_idx == #self.path and len_to_point < bs * 3 then
        self.set_human_near_exit(e)
    end

    if len_to_point < 1 then
        self.current_node_idx = self.current_node_idx + 1
    end

    local direction = pos_to_point:normalized()
    local distance_to_move = direction
    e:set_position(current_pos + distance_to_move)
    self.data.restlessness = math.max(0, self.data.restlessness - distance_to_move:len() * 0.01)
    return self
end
