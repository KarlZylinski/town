require "class"
require "world"
require "vector2"
require "house"
require "human/human"
require "tree"
require "bed"

local path = "pvx.dll"
assert(package.loadlib(path, "pvx_load"))()
pvx_init("StadKul", 1280, 720)
bs = 32
Entity.static_init()
current_tick = 0
left_button_pressed_callbacks = {}
right_button_pressed_callbacks = {}

function tick_state(state, data)
    local new_state = state:tick()

    if new_state ~= state then
        if state.exit ~= nil then
            state:exit()
        end

        enter_state(new_state, data)
    end

    return new_state
end

function enter_state(state, data)
    state.data = data
    state:enter()
end

function move_to_world(entity, new_world)
    assert(new_world ~= nil)
    assert(entity.world ~= nil)
    entity.world:remove_entity(entity)
    new_world:add_entity(entity)
end

function find_waypoints(from_world, to_entity)
    local destination_world = to_entity.world

    if from_world == destination_world then
        return {
            {
                position = to_entity:get_interact_pos(),
                world = destination_world
            }
        }
    end

    local exits = from_world:get_exits()

    for i, exit in ipairs(exits) do
        if exit.world == destination_world then
            return {
                {
                    set_proximity = exit.set_human_near_exit,
                    waypoint_reached = function(entity)
                        move_to_world(entity, exit.world)
                    end,
                    position = exit.position,
                    world = from_world
                },
                {
                    position = to_entity:get_interact_pos(),
                    world = destination_world
                }
            }
        end
    end

    return nil
end

function bounds_intersect(a, b)
    return a.left <= b.right and
           b.left <= a.right and
           a.top <= b.bottom and
           b.top <= a.bottom
end

function bounds_contains(b, p)
    return p.x >= b.left and p.y >= b.top and p.x <= b.right and p.y <= b.bottom
end

function pos_to_coords(pos)
    return Vector2(math.floor(pos.x / bs), math.floor(pos.y / bs))
end

local houses_per_unit = 0.08
local trees_per_unit = 0.01

function generate_world(size, world)
    local entities = {}
    local exits = {}
    local world_bounds = {}

    function find_free_ran_pos(w, h, align)
        function rand_bounds()
            padding_x = padding_x or 5
            padding_y = padding_y or 5
            local x, y = math.random(-((size.x + padding_x) * bs)/2, ((size.x + padding_x) * bs)/2), math.random(-((size.y + padding_y) * bs)/2, ((size.y + padding_y) * bs)/2)
            --local x, y = math.random(5, ((size.x + padding_y) * bs) ), math.random(5, ((size.y + size_x) * bs))
            
            if align then
                x = x - x % bs
                y = y - y % bs
            end

            local left, top = x - w/2 * bs - bs, y - h * bs - bs
            local right, bottom = x + w/2 * bs + bs, y + bs + bs

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
                return Vector2(x, y)
            end
        end

        return nil
    end

    for i=1, size.x * bs * houses_per_unit do
        local w, h = math.random(7,60), math.random(6, 15)
        local position = find_free_ran_pos(w, h, true)

        if position ~= nil then
            local house_act = HouseAct(Vector2(w, h), position)
            local entity = Entity(position, house_act, world)
            entity:start()
            local entity_exits = entity:get_exits()

            for _, exit in ipairs(entity_exits) do
                table.insert(exits, exit)
            end

            local entity_bounds = entity:get_bounds()

            if world_bounds.left == nil or entity_bounds.left < world_bounds.left then
                world_bounds.left = entity_bounds.left
            end

            if world_bounds.top == nil or entity_bounds.top < world_bounds.top then
                world_bounds.top = entity_bounds.top
            end

            if world_bounds.right == nil or entity_bounds.right > world_bounds.right then
                world_bounds.right = entity_bounds.right
            end

            if world_bounds.bottom == nil or entity_bounds.bottom > world_bounds.bottom then
                world_bounds.bottom = entity_bounds.bottom
            end

            table.insert(entities, entity)
        end
    end

    for i=1,size.x * bs * trees_per_unit do
        local position = find_free_ran_pos(2, 2, false)

        if position ~= nil then
            local tree_act = TreeAct()
            local entity = Entity(position, tree_act, world)
            entity:start()
            table.insert(entities, entity)
        end
    end

    return entities, exits, world_bounds
end

local world_size = Vector2(80, 50)

math.randomseed(os.clock())
grass_color = {r = 0.443, g = 0.678, b = 0.169 }
main_world = World(generate_world, world_size)
local time_multiplier = 100
local time_per_tick = 1/time_multiplier
local camera_move_speed = 2000
local time_last_tick = os.clock()
local time_last_frame = os.clock()
main_world:start()

for _, entity in ipairs(main_world.entities) do
    if is(entity.act, HouseAct) and entity.act.inside_world ~= nil then
        local bed_act = BedAct()
        local bed = Entity(entity.act:find_free_area_along_wall(Vector2(bs * 1.5, bs * 2)), bed_act, entity.act.inside_world)
        entity.act.inside_world:add_entity(bed)
        entity.act.inside_world.bed = bed
        local human_act = HumanAct(entity)
        local human = Entity(entity.act:find_free_location(), human_act, entity.act.inside_world)
        entity.act.inside_world:add_entity(human)
    end
end

local left_button_held_last_frame = false
local right_button_held_last_frame = false
local left_button_pressed = false
local right_button_pressed = false

while pvx_is_window_open() do
    local current_time = os.clock()
    local frame_dt = current_time - time_last_frame
    time_last_frame = current_time
    local camera_move_x = 0
    local camera_move_y = 0

    if (pvx_key_held("left")) then
        camera_move_x = frame_dt * -camera_move_speed
    end

    if (pvx_key_held("right")) then
        camera_move_x = frame_dt * camera_move_speed
    end

    if (pvx_key_held("up")) then
        camera_move_y = frame_dt * -camera_move_speed
    end

    if (pvx_key_held("down")) then
        camera_move_y = frame_dt * camera_move_speed
    end

    if camera_move_x ~= 0 or camera_move_y ~= 0 then
        pvx_move_view(camera_move_x, camera_move_y)
    end

    local left_mouse_held = pvx_left_mouse_held()
    
    if left_mouse_held and not left_button_held_last_frame then
        left_button_pressed = true
    end

    left_button_held_last_frame = left_mouse_held
    local right_mouse_held = pvx_right_mouse_held()
    
    if right_mouse_held and not right_button_held_last_frame then
        right_button_pressed = true
    end

    right_button_held_last_frame = right_mouse_held

    if current_time - time_last_tick > 1/time_multiplier then
        local mouse_pos = Vector2(pvx_mouse_pos())
        local view_size = Vector2(pvx_window_size())
        local view_pos = Vector2(pvx_view_pos())
        local world_pos = view_pos + mouse_pos
        local screet_rect_padding = bs * 4

        local screen_rect = {
            left = view_pos.x - screet_rect_padding,
            top = view_pos.y - screet_rect_padding,
            right = view_pos.x + view_size.x + screet_rect_padding,
            bottom = view_pos.y + view_size.y + screet_rect_padding
        }

        if left_button_pressed then
            local containing_entity = main_world:get_containing_entity(world_pos)

            if containing_entity ~= nil then
                containing_entity:left_mouse_clicked(world_pos)
            end

            for _, f in ipairs(left_button_pressed_callbacks) do
                f(mouse_pos, world_pos)
            end
        end

        if right_button_pressed then
            local containing_entity = main_world:get_containing_entity(world_pos)

            if containing_entity ~= nil then
                containing_entity:right_mouse_clicked(world_pos)
            end

            for _, f in ipairs(right_button_pressed_callbacks) do
                f(mouse_pos, world_pos)
            end
        end

        pvx_process_events()
        pvx_clear(grass_color.r, grass_color.g, grass_color.b)
        main_world:tick()
        main_world:draw(screen_rect)
        time_last_tick = current_time
        pvx_flip()

        left_button_pressed = false
        right_button_pressed = false
    end
end

pvx_deinit()
