function create_person()
    function create_wake_up_state()
        local state = {}

        function state:enter()
            print("waking up")
        end

        function state:exit()
        end

        function state:tick()
            return self
        end

        return state
    end

    function create_sleeping_state()
        local state = {}

        function state:enter()
            self.sleepiness = 1.0
            self.sleep_depth = 0.1
            self.time_slept = 0
        end

        function state:exit()
        end

        function state:tick()
            self.time_slept = self.time_slept + 1
            sleep_time = 25200.0
            self.sleep_depth = self.sleep_depth + (self.sleepiness - 0.5) / sleep_time
            self.sleepiness = self.sleepiness - 1.0 / sleep_time

            if self.sleep_depth <= 0 then
                return create_wake_up_state()
            end

            print(self.time_slept / 3600, " hours")
            return self
        end

        return state
    end

    return {
        state = create_sleeping_state()
    }
end

function tick(persons)
    for _, person in ipairs(persons) do
        local new_state = person.state:tick()

        if new_state ~= person.state then
            person.state:exit()
            new_state:enter()
        end

        person.state = new_state
    end
end

math.randomseed(os.time())
local ticks_per_second = 1000
local time_last_tick = os.clock()
local persons = { create_person() }

for _, person in ipairs(persons) do
    person.state:enter()
end

while true do
    local current_time = os.clock()

    -- Make this distribute the tick calls throughout the second.
    if current_time - time_last_tick > 1 then
        time_last_tick = current_time

        for i=1, ticks_per_second do
            tick(persons)
        end
    end
end

