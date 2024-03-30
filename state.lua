local class = require "middleclass"

local State = class("State")


function State:initialize()
    self.StateType = { PLAYING = 1, PLAYER_GUESSING = 2, PLAYER_STEALING = 3, END = 4, START_SCREEN = 5 }
    self.state = self.StateType.PLAYING
end

function State:changeState(newState)
    self.state = newState
end

return State
