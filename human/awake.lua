require "human/sleep"

HumanAwakeState = class(HumanAwakeState)

function HumanAwakeState:enter()
    print("woke up")
end

function HumanAwakeState:exit()
end

function HumanAwakeState:tick()
    if self.data.sleepiness >= 1 then
        return HumanSleepState()
    end

    normal_day_length = 61200
    self.data.sleepiness = self.data.sleepiness + 1 / normal_day_length
    return self
end
