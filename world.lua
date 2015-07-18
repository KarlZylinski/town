require "entity"

World = class(World)

function World:init(generation_func, size)
    self.entities, self.exits = generation_func(size, self)
end

function World:start()
    if self.entities == nil then
        return
    end

    for _, entity in ipairs(self.entities) do
        entity:start()
    end
end

function World:tick()
    if self.entities == nil then
        return
    end

    for _, entity in ipairs(self.entities) do
        entity:tick()
    end

    current_tick = current_tick + 1
end

function World:draw(screen_rect)
    if self.entities == nil then
        return
    end

    local entities_on_screen = {}

    for _, entity in ipairs(self.entities) do
        if bounds_intersect(entity:get_bounds(), screen_rect) then
            table.insert(entities_on_screen, entity)
        end
    end

    for _, entity in ipairs(entities_on_screen) do
        entity:draw(screen_rect)
    end
end

function World:get_intersecting_entity(pos)
    for _, entity in ipairs(self.entities) do
        if entity:contains(pos) then
            return entity
        end
    end

    return nil
end

function World:add_entity(entity)
    table.insert(self.entities, entity)

    if entity.started == false then
        entity:start()
    end

    entity.world = self
end

function World:remove_entity(entity)
    local entity_index = -1

    for i, e in ipairs(self.entities) do
        if entity == e then
            entity_index = i
            break
        end
    end

    assert(entity_index ~= -1)
    table.remove(self.entities, entity_index)
end

function World:get_exits()
    return self.exits
end