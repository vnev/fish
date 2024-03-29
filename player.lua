local class = require "middleclass"
local math = require "math"

local Player = class("Player")

function Player:initialize(hand, teamid)
    self.hand = hand
    self.teamid = teamid
    self.id = math.random()
    self.isactive = true
end

function Player:update()
    self.hand:update()
end

function Player:draw()
    self.hand:draw()
end

function Player:give(cardid)
    -- give from our deck
    local res = self.hand:remove(cardid)
    if self.hand:count() == 0 then
        self.isactive = false
    end
    return res
end

function Player:take(card)
    -- add to our deck
    self.hand:add(card)
end

return Player
