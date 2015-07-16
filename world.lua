require "human/human"
require "house"

World = class(World)

local world_width = 20000
local world_height = 20000
local houses_per_unit = 0.08

function generate_world()
    local entities = {}

    for i=1, world_width * houses_per_unit do
        function find_free_ran_pos(w, h)
            function rand_bounds()
                local x, y = math.random(-world_width/2, world_width/2), math.random(-world_height/2, world_height/2)
                local left, top = x - w/2 * bs, y - h * bs
                local right, bottom = x + w/2 * bs, y + bs

                local bounds = {
                    left = left, top = top, right = right, bottom = bottom
                }

                return bounds, x, y
            end

            local bounds, x, y = rand_bounds()

            for i=1,10 do
                local free = true
                
                for _, entity in ipairs(entities) do
                    if entity.bounds ~= nil then
                        if bounds_intersect(bounds, entity.bounds) then
                            bounds, x, y = rand_bounds()
                            free = false
                            break
                        end
                    end
                end

                if free == true then
                    return x, y
                end
            end

            return nil
        end

        local w, h = math.random(4,10), math.random(3, 6)
        local x, y = find_free_ran_pos(w, h)

        if x ~= nil and y ~= nil then
            local house = House(x, y, w, h)
            table.insert(entities, house)
        end
    end

    table.sort(entities, function(e1, e2)
        return e1.y < e2.y
    end)

    return entities
end

function World:init()
    self.entities = generate_world()
end

function World:start()
    for _, entity in ipairs(self.entities) do
        if entity.start ~= nil then
            entity:start()
        end
    end
end

function World:tick()
    for _, entity in ipairs(self.entities) do
        if entity.tick ~= nil then
            entity:tick()
        end
    end

    current_tick = current_tick + 1
end

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function World:draw()
    for _, entity in ipairs(self.entities) do
        if entity.draw ~= nil then
            entity:draw()
        end
    end
end