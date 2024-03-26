local class = require("middleclass")
local math = require("math")

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
end

return Player
