require "entity"

World = class(World)

function World:init(generation_func, size)
    self.entities, self.exits, self.extents = generation_func(size, self)
    self.squares = {}
end

function World:start()
    if self.entities == nil then
        return
    end

    local square_extents = {
        left = math.floor(self.extents.left / bs - 20),
        top = math.floor(self.extents.top / bs - 20),
        right = math.floor(self.extents.right / bs + 20),
        bottom = math.floor(self.extents.bottom / bs + 20)
    }

    for x = square_extents.left, square_extents.right do
        for y = square_extents.top, square_extents.bottom do
            local pos = Vector2(x * bs + bs / 2, y * bs + bs / 2)
            local entity = self:get_containing_entity(pos)
            local blocking = entity ~= nil and entity:is_blocking(pos)

            local square = {
                coords = Vector2(x, y),
                position = pos,
                blocking = blocking
            }

            local x_list = self.squares[x]

            if x_list == nil then
                x_list = {}
                self.squares[x] = x_list
            end

            x_list[y] = square
        end
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

    table.sort(entities_on_screen, function(e1, e2)
        return e1:get_position().y < e2:get_position().y
    end)

    for _, entity in ipairs(entities_on_screen) do
        entity:draw(screen_rect)
    end
end

function World:get_containing_entity(pos)
    for _, entity in ipairs(self.entities) do
        if entity:contains(pos) then
            return entity
        end
    end

    return nil
end

function World:get_intersecting_entity(bounds)
    for _, entity in ipairs(self.entities) do
        if bounds_intersect(entity:get_bounds(), bounds) then
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

function World:get_square(coord)
    local sq_x_list = self.squares[coord.x]

    if sq_x_list == nil then
        return nil
    end

    local square = sq_x_list[coord.y]

    if square == nil then
        return nil
    end

    copy = {}

    for orig_key, orig_value in pairs(square) do
        copy[orig_key] = orig_value
    end

    return copy
end

function sleep(n)  -- seconds
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end

function World:find_path(start_pos, end_pos)
    local start_coords = pos_to_coords(start_pos)
    local end_coords = pos_to_coords(end_pos)
    local start_square = self:get_square(start_coords)
    local end_square = self:get_square(end_coords)

    if start_square == nil or end_square == nil then
        return nil
    end

    assert(not start_square.is_blocking and not end_square.is_blocking)

    function manhattan_distance(from, to)
        local x = Vector2(to.x - from.x, 0):len()
        local y = Vector2(to.y - from.y, 0):len()
        return x + y
    end

    function recalc_score(sq)
        sq.H = manhattan_distance(sq.coords, end_coords)

        if sq.parent == nil then
            sq.G = 0
        else
            sq.G = sq.parent.G + (sq.coords - sq.parent.coords):len_sq()
        end

        sq.F = sq.G + sq.H
    end

    local current_square
    local open = {}
    recalc_score(start_square)
    table.insert(open, start_square)
    local closed = {}
    local search_offsets = {
        Vector2(-1, 0),
        --Vector2(-1, -1),
        Vector2(0, -1),
        --Vector2(1, -1),
        Vector2(1, 0),
        --Vector2(1, 1),
        Vector2(0, 1),
        --Vector2(-1, 1)
    }

    function add_to_open(sq)
        sq.parent = current_square
        recalc_score(sq)
        table.insert(open, sq)
    end

    function find_index(list, sq)
        for i, square in ipairs(list) do
            if square.coords == sq.coords then
                return i
            end
        end

        return -1
    end

    function reparent_square(square, new_parent)
        square.parent = new_parent
        recalc_score(square)
    end

    function find_best_square()
        if #open == 0 then
            return nil
        end

        local best_square, idx = open[1], 1

        for i, sq in ipairs(open) do
            if sq ~= best_square and sq.F < best_square.F then
                best_square, idx = sq, i
            end

            if sq.coords == end_square.coords then
                return sq, i
            end
        end

        return best_square, idx
    end

    function advance()
        current_square, idx = find_best_square()
        table.remove(open, idx)
        table.insert(closed, current_square)

        if current_square.coords == end_square.coords then
            return true
        end

        function find_nearby_walkable_squares(from)
            local walkable_squares = {}

            for _, offset in ipairs(search_offsets) do
                local coords = from.coords + offset
                local sq = self:get_square(coords)

                if sq ~= nil and not sq.blocking and find_index(closed, sq) == -1 then
                    table.insert(walkable_squares, sq)
                end
            end

            return walkable_squares
        end

        local nearby_squares = find_nearby_walkable_squares(current_square)

        for _, sq in ipairs(nearby_squares) do
            local idx = find_index(open, sq)
            if idx == -1 then
                add_to_open(sq)
            else
                local sq = open[idx]

                if current_square.G + (sq.coords - current_square.coords):len_sq() < sq.G then
                    reparent_square(sq, current_square)
                end
            end
        end

        return false
    end

    local path_found = false

    while #open > 0 do
        if advance() then
            path_found = true
            break
        end
    end

    function reverse_table(t)
        local reversed_table = {}
        local count = #t

        for k, v in ipairs(t) do
            reversed_table[count + 1 - k] = v
        end

        return reversed_table
    end

    if path_found then
        local path = {}

        while current_square.parent ~= nil do
            table.insert(path, current_square)
            current_square = current_square.parent
        end

        return reverse_table(path)
    end

    return nil
end

function World:get_exits()
    return self.exits
end