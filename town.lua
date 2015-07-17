require "class"
require "world"
require "vector2"

local path = "pvx.dll"
assert(package.loadlib(path, "pvx_load"))()
pvx_init("StadKul", 800, 600)
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

function bounds_intersect(sb, ob)
    local ow, oh = ob.right - ob.left, ob.bottom - ob.top
    local sw, sh = sb.right - sb.left, sb.bottom - sb.top
    local ox, oy = ob.left, ob.top
    local sx, sy = sb.left, sb.top
    return math.abs(sx - ox) * 2 < (ow + sw) and math.abs(sy - oy) * 2 < (oh + sh)
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
        pvx_clear(0.1, 0.51, 0.054)
        world:tick()
        world:draw()
        time_last_tick = current_time
        pvx_flip()
    end
end

pvx_deinit()
