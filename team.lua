local love = require "love"
local class = require "middleclass"
local math = require "math"

local Team = class("Team")

function Team:initialize(teamid, card_back_image) -- players -> list of player IDs
    self.players = {}
    self.score = 0
    self.hands_won = 0
    self.id = teamid
    self.card_batches = {}
    self.isstealing = false
    self.card_back_image = card_back_image
    self.batch_startx, self.batch_starty = 150, 70
end

function Team:updatebatch()
    if #self.card_batches == 0 then
        for i = 1, #self.players, 1 do
            local player = self.players[i]
            local batch = love.graphics.newSpriteBatch(self.card_back_image, #player.hand.cards)
            table.insert(self.card_batches, batch)
        end
    end
    local x, y = self.batch_startx, self.batch_starty

    for j = 1, #self.players, 1 do
        local rotate = 0.0
        self.card_batches[j]:clear()
        if self.players[j].isactive then
            for i = 1, #self.players[j].hand.cards, 1 do
                self.card_batches[j]:add(x, y, rotate, 1.5, 1.5)
                rotate = rotate + 0.01
            end
        end
        x = x + 300
    end
end

function Team:addpoint(points) -- normally would just be 1, except for the team that wins the first hand (which is worth 2 points)
    self.score = self.score + points
    self.hands_won = self.hands_won + 1
end

function Team:addplayer(player)
    table.insert(self.players, player)
end

function Team:update()
    self:updatebatch()
end

function Team:draw()
    if not self.isstealing then
        for i = 1, #self.card_batches, 1 do
            love.graphics.draw(self.card_batches[i], 0, 0)
        end
    end
end

return Team
