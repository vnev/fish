local class = require "middleclass"

local State = class("State")


function State:initialize()
    self.StateType = { PLAYING = 1, PLAYER_GUESSING = 2, PLAYER_STEALING = 3, END = 4, START_SCREEN = 5, CONNECTING = 6, CREATING_GAME = 7, JOINING_GAME = 8 }
    self.state = self.StateType.CREATING_GAME
end

function State:changeState(newState)
    self.state = newState
end

return State
