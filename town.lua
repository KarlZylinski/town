require "class"
require "world"

local path = "pvx.dll"
assert(package.loadlib(path, "pvx_load"))()
pvx_init("StadKul", 800, 600)

local shape = pvx_add_shape(1, 0, 0, {
    0, 0,
    100, 0,
    100, 100,
    0, 100
})

local shape2 = pvx_add_shape(1, 0, 1, {
    0, 0,
    100, 0,
    100, 100,
    0, 100
})

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

math.randomseed(os.time())
local world = World()
local time_multiplier = 100
local time_last_tick = os.clock()
world:start()

while pvx_is_window_open() do
    local current_time = os.clock()

    if current_time - time_last_tick > 1/time_multiplier then
        pvx_process_events()
        pvx_clear()
        world:tick()
        world:draw()
        time_last_tick = current_time
        pvx_draw_shape(shape2, 50, 50)
        pvx_flip()
    end
end

pvx_deinit()
