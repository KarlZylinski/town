require "class"
require "world"
require "vector2"
require "house"

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

function bounds_intersect(a, b)
    return a.left <= b.right and
           b.left <= a.right and
           a.top <= b.bottom and
           b.top <= a.bottom
end

function bounds_contains(b, p)
    return p.x >= b.left and p.y >= b.top and p.x <= b.right and p.y <= b.bottom
end

local houses_per_unit = 0.08

function generate_world(size)
    local entities = {}

    for i=1, size.x * bs * houses_per_unit do
        function find_free_ran_pos(w, h)
            function rand_bounds()
                local x, y = math.random(-(size.x * bs)/2, (size.x * bs)/2), math.random(-(size.y * bs)/2, (size.y * bs)/2)
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
                    return Vector2(x, y)
                end
            end

            return nil
        end

        local w, h = math.random(7,60), math.random(5, 12)
        local position = find_free_ran_pos(w, h)

        if position ~= nil then
            local house_act = HouseAct(Vector2(w, h))
            local entity = Entity(position, house_act)
            table.insert(entities, entity)
        end
    end

    table.sort(entities, function(e1, e2)
        return e1:get_position().y < e2:get_position().y
    end)

    return entities
end

local world_size = Vector2(60, 60)

math.randomseed(os.time())
grass_color = {r = 0.443, g = 0.678, b = 0.169 }
local main_world = World(generate_world, world_size)
local time_multiplier = 100
local time_per_tick = 1/time_multiplier
local camera_move_speed = 2000
local time_last_tick = os.clock()
local time_last_frame = os.clock()
main_world:start()
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
        local adjusted_view_pos = view_pos
        local world_pos = adjusted_view_pos + mouse_pos

        if left_button_pressed then
            local intersecting_entity = main_world:get_intersecting_entity(world_pos)

            if intersecting_entity ~= nil then
                intersecting_entity:left_mouse_clicked(world_pos)
            end

            for _, f in ipairs(left_button_pressed_callbacks) do
                f(mouse_pos, world_pos)
            end
        end

        if right_button_pressed then
            local intersecting_entity = main_world:get_intersecting_entity(world_pos)

            if intersecting_entity ~= nil then
                intersecting_entity:right_mouse_clicked(world_pos)
            end

            for _, f in ipairs(right_button_pressed_callbacks) do
                f(mouse_pos, world_pos)
            end
        end

        pvx_process_events()
        pvx_clear(grass_color.r, grass_color.g, grass_color.b)
        main_world:tick()
        main_world:draw()
        time_last_tick = current_time
        pvx_flip()

        left_button_pressed = false
        right_button_pressed = false
    end
end

pvx_deinit()
