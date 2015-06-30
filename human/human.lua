require "human/awake"

Human = class(Human)

function Human:init()
    self.data = {
        sleepiness = 0.2
    }

    self.state = HumanAwakeState()
end

function Human:start()
    enter_state(self.state, self.data)
end

function Human:tick()
    self.state = tick_state(self.state, self.data)
end
