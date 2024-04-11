local love = require "love"
local class = require "middleclass"

local Team = class("Team")

function Team:initialize(teamid, card_back_image) -- players -> list of player IDs
    self.players = {}                             -- player ID trailer
    self.score = 0
    self.hands_won = 0
    self.id = teamid
    self.card_batches = {}
    self.isstealing = false
    self.card_back_image = card_back_image
    self.batch_startx, self.batch_starty = 150, 70
end

function Team:updatebatch()
    if self.card_batches ~= 3 then
        self.card_batches = {}
        for i = 1, #self.players, 1 do
            table.insert(self.card_batches,
                { batch = love.graphics.newSpriteBatch(self.card_back_image, 8), x = 0, y = 0 })
        end
    end

    local x, y = self.batch_startx, self.batch_starty
    for j = 1, #self.players, 1 do
        local rotate = 0.0
        self.card_batches[j].batch:clear()
        for i = 1, 8, 1 do
            self.card_batches[j].x = x
            self.card_batches[j].y = y
            self.card_batches[j].batch:add(x, y, rotate, 1.5, 1.5)
            rotate = rotate + 0.01
        end
        x = x + 300
    end
end

function Team:getdeckclicked(x, y)

end

function Team:addpoint(points) -- normally would just be 1, except for the team that wins the first hand (which is worth 2 points)
    self.score = self.score + points
    self.hands_won = self.hands_won + 1
end

function Team:addplayer(player)
    table.insert(self.players, player)
    print('added player to team. new team total: ' .. #self.players)
end

function Team:update()
    self:updatebatch()
end

function Team:draw()
    for i = 1, #self.card_batches, 1 do
        love.graphics.draw(self.card_batches[i].batch, 0, 0)
    end
end

return Team
