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
    return bounds_intersect(self:bounds(), other:bounds())
end

function Entity:set_position(position)
    assert(position ~= nil)
    self.position = position
    self.bounds = self.act:calc_bounds(position)
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

    self.act:draw(self.position)
end