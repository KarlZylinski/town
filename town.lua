require "class"
require "human/human"
require "human/sleep"
require "human/awake"

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

function tick(humans)
    for _, human in ipairs(humans) do
        human:tick()
    end

    current_tick = current_tick + 1
end

math.randomseed(os.time())
local time_multiplier = 10000
local time_last_tick = os.clock()
local humans = { Human() }

for _, human in ipairs(humans) do
    human:start()
end

while true do
    local current_time = os.clock()

    if current_time - time_last_tick > 1/time_multiplier then
        time_last_tick = current_time
        tick(humans)
    end
end

