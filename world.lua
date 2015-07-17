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
        if entity.start ~= nil then
            entity:start()
        end
    end
end

function World:tick()
    if self.entities == nil then
        return
    end

    for _, entity in ipairs(self.entities) do
        if entity.tick ~= nil then
            entity:tick()
        end
    end

    current_tick = current_tick + 1
end

function World:draw()
    if self.entities == nil then
        return
    end
    
    for _, entity in ipairs(self.entities) do
        if entity.draw ~= nil then
            entity:draw()
        end
    end
end