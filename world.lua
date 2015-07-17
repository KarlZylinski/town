require "entity"

World = class(World)

function World:init(generation_func, size)
    self.entities = generation_func(size)
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

function World:draw()
    if self.entities == nil then
        return
    end

    for _, entity in ipairs(self.entities) do
        entity:draw()
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