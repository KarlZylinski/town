require "class"
require "world"
require "vector2"
require "house"

local path = "pvx.dll"
assert(package.loadlib(path, "pvx_load"))()
pvx_init("StadKul", 1800, 950)
bs = 32
Entity.static_init()
current_tick = 0

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
local camera_move_speed = 5
local time_last_tick = os.clock()
local time_last_frame = os.clock()
main_world:start()

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

    if current_time - time_last_tick > 1/time_multiplier then
        pvx_process_events()
        pvx_clear(grass_color.r, grass_color.g, grass_color.b)
        main_world:tick()
        main_world:draw()
        time_last_tick = current_time
        pvx_flip()
    end
end

pvx_deinit()

function key_down(key)
    print(key)
end

function key_up(key)
    print(key)
end
