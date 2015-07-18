HumanSleepRemState = class(HumanSleepRemState)

local normal_sleep_length = 25200.0

function HumanSleepRemState:init()
    rem_base_length = 2520
    self.rem_until = current_tick + rem_base_length + math.random(-500, 500)
end

function HumanSleepRemState:enter()
end

function HumanSleepRemState:exit()
end

function HumanSleepRemState:tick()
    if current_tick > self.rem_until then
        return HumanSleepDeepState()
    end

    self.data.sleepiness = self.data.sleepiness - 1 / normal_sleep_length * 2
    return self
end


HumanSleepDeepState = class(HumanSleepDeepState)

function HumanSleepDeepState:init()
    base_deep_sleep_length = 5000
    self.next_rem_at = current_tick + base_deep_sleep_length + math.random(-1000, 1200)
end

function HumanSleepDeepState:enter()
    print("entering deep sleep")
end

function HumanSleepDeepState:exit()
    print("leaving deep sleep")
end

function HumanSleepDeepState:tick()
    if current_tick > self.next_rem_at then
        return HumanSleepRemState()
    end

    self.data.sleepiness = self.data.sleepiness - 1 / normal_sleep_length / 2
    return self
end


HumanSleepState = class(HumanSleepState)

function HumanSleepState:init()
    self.sub_state = HumanSleepDeepState(1.0)
end

function HumanSleepState:enter()
    print("fell asleep")
    enter_state(self.sub_state, self.data)
end

function HumanSleepState:exit()
end

function HumanSleepState:tick()
    self.sub_state = tick_state(self.sub_state, self.data)

    if self.data.sleepiness <= 0 then
        return HumanAwakeState()
    end

    return self
end
