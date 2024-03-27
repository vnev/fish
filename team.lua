local class = require "middleclass"
local math = require "math"

local Team = class("Team")

function Team:initialize(playerids) -- players -> list of player IDs
    self.playerids = playerids
    self.score = 0
    self.hands_won = 0
    self.teamid = math.random()
end

function Team:addpoint(points) -- normally would just be 1, except for the team that wins the first hand (which is worth 2 points)
    self.score = self.score + points
    self.hands_won = self.hands_won + 1
end

function Team:update()
end

function Team:draw()
end

return Team
