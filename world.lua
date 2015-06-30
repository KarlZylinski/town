require "human/human"
require "house"

World = class(World)

function generate_world()
    local entities = {}

    for i=1, 5 do
        local house = House()
        local x, y = math.random(1, 80), math.random(1, 25)
        house:set_position(x, y)
        table.insert(entities, house)
    end

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
    os.execute("cls")
    local screen = ""
    width = 80
    height = 25
    
    for i = 1, width * height do
        screen = screen .. " "
    end

    for _, entity in ipairs(self.entities) do
        if entity.art ~= nil and entity.position ~= nil then
            local world_x, world_y = entity:position()
            local w, h = entity:size()
            local art = entity:art()
            local r = 0
            local x = 0
            local y = 0

            for i = 1, #art do
                local c = art:sub(i, i)

                if c == '\n' then
                    r = r + 1
                    y = y + 1
                    x = 0
                else
                    x = x + 1
                    local pos = (world_y + y) * width + x + world_x
                    screen = replace_char(pos, screen, c)
                end
            end
        end
    end

    print(screen)
end