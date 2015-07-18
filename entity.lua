Entity = class(Entity)

Entity.static_init_funcs = {}
Entity.all_entities = {}

function Entity.static_init()
    for _, init_func in ipairs(Entity.static_init_funcs) do
        init_func()
    end
end

function Entity.add_static_init_func(init_func)
    table.insert(Entity.static_init_funcs, init_func)
end

function Entity:init(position, act, world)
    assert(position ~= nil)
    assert(act ~= nil)
    assert(act.get_size ~= nil)
    assert(act.calc_bounds ~= nil)
    assert(world ~= nil)
    self.world = world
    self.position = position
    self.act = act
    self.act.entity = self
    self.bounds = self.act:calc_bounds(position)
    self.started = false
    table.insert(Entity.all_entities, self)
end

function Entity:deinit()
    for i, entity in ipairs(Entity.all_entities) do
        if entity == self then
            table.remove(Entity.all_entities, i)
            break
        end
    end
end

function Entity:set_move_direction(direction)
    self.move_direction = direction
end

function Entity:get_bounds()
    return self.bounds
end

function Entity:get_position()
    return self.position
end

function Entity:get_size()
    return self.act:get_size()
end

function Entity:intersects(other)
    assert(other ~= nil)
    return bounds_intersect(self:get_bounds(), other:get_bounds())
end

function Entity:contains(pos)
    assert(pos ~= nil)
    return bounds_contains(self:get_bounds(), pos)
end

function Entity:set_position(position)
    assert(position ~= nil)
    self.position = position
    self.bounds = self.act:calc_bounds(position)
end

function Entity:is_blocking(pos)
    if self.act.is_blocking == nil then
        return false
    end

    return self.act:is_blocking(pos)
end

function Entity:start()
    if self.started == true then
        return
    end

    self.started = true

    if self.act.start == nil then
        return
    end

    self.act:start()
end

function Entity:tick()
    if self.act.tick == nil then
        return
    end

    self.act:tick()

    if self.move_direction ~= nil then
        self:set_position(self:get_position() + self.move_direction * self:get_speed())
        self.move_direction = nil
    end
end

function Entity:draw(screen_rect)
    if self.act.draw == nil then
        return
    end

    self.act:draw(screen_rect)
end

function Entity:get_speed()
    if self.act.get_speed == nil then
        return 1
    end

    return self.act:get_speed()
end

function Entity:left_mouse_clicked(pos)
    if self.act.left_mouse_clicked == nil then
        return
    end

    self.act:left_mouse_clicked(pos)
end

function Entity:right_mouse_clicked(pos)
    if self.act.right_mouse_clicked == nil then
        return
    end

    self.act:right_mouse_clicked(pos)
end

function Entity:get_exits()
    if self.act.get_exits == nil then
        return {}
    end

    return self.act:get_exits()
end

function Entity:get_interact_pos()
    if self.act.get_interact_pos == nil then
        return self:get_position()
    end

    return self.act:get_interact_pos()
end

function Entity:is_danceable()
    if self.act.is_danceable == nil then
        return false
    end

    return self.act:is_danceable()
end
