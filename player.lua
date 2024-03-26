local class = require "middleclass"
local math = require "math"

local Player = class("Player")

function Player:initialize(teamid, hand)
    self.hand = hand
    self.teamid = teamid
    self.id = math.random()
end

function Player:update()
    self.hand:update()
end

function Player:draw()
    self.hand:draw()
end

function Player:give(cardid)
    -- give from our deck
    return self.hand:remove(cardid)
end

function Player:take(card)
    -- add to our deck
    self.hand:add(card)
end

return Player
