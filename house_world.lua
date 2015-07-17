-- Inside house
require "wall"

function generate_house_world(position, placements, shapes, size)
    local entities = {}

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
                table.insert(entities, Entity(position + Vector2(x, y) * bs, WallAct(shape)))
            end
        end
    end

    return entities
end
