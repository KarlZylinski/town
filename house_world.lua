-- Inside house
require "wall"
require "floor"

local floor_shape_cache = {}

local function get_or_add_floor_shape(size)
    local key = tostring(size.x) .. " " .. tostring(size.y)
    local existing = floor_shape_cache[key]

    if existing ~= nil then
        return existing
    end

    local shape = {
        0, 0,
        size.x * bs, 0,
        size.x * bs, size.y * bs,
        0, size.y * bs
    }

    local handle = pvx_add_shape(0.76, 0.72, 0.67, shape)
    floor_shape_cache[key] = handle
    return handle
end

function generate_house_world(position, placements, shapes, parent_world, size, world)
    local entities = {}
    local floor_size = size - Vector2(2, 0)
    table.insert(entities, Entity(position + Vector2(bs * 2, bs), FloorAct(get_or_add_floor_shape(floor_size), floor_size), world))
    local l = 1
    local t = 1
    local r = size.x
    local b = size.y

    function get_shape(pos)
        local x = pos.x
        local y = pos.y

        if x == l then
            return shapes.left_side
        end

        if x == r then
            return shapes.right_side
        end

        if x == l + 1 and x  then
            return shapes.wall
        end

        if x == r - 1 then
            return shapes.wall
        end

        if (y == b or y == b - 1) and x ~= placements.door_x then
            return shapes.wall
        end

        if y == 1 then
            return shapes.wall
        end

        return nil
    end

    for x = 1, size.x do
        for y = 1, size.y do
            local shape = get_shape(Vector2(x, y))

            if shape ~= nil then
                table.insert(entities, Entity(position + Vector2(x, y) * bs, WallAct(shape), world))
            end
        end
    end

    assert(parent_world ~= nil)

    local exits = {
        {
            position = Vector2(position.x + bs/2 + placements.door_x * bs, position.y + (size.y + 1) * bs),
            world = parent_world
        }
    }

    return entities, exits
end
