Entity = class(Entity)

Entity.static_init_funcs = {}

function Entity.static_init()
    for _, init_func in ipairs(Entity.static_init_funcs) do
        init_func()
    end
end

function Entity.add_static_init_func(init_func)
    table.insert(Entity.static_init_funcs, init_func)
end

function Entity:init(position, act)
    assert(position ~= nil)
    assert(act ~= nil)
    assert(act.get_size ~= nil)
    assert(act.calc_bounds ~= nil)
    self.position = position
    self.act = act
    self.act.entity = self
    self.bounds = self.act:calc_bounds(position)
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

function Entity:start()
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
end

function Entity:draw()
    if self.act.draw == nil then
        return
    end

    self.act:draw()
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
