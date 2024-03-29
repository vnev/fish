local love = require "love"
local class = require "middleclass"
local Team = require "team"
local Deck = require "deck"
local Hand = require "hand"
local Player = require "player"
local Utils = require "utils"
local AssetLoader = require "asset_loader"

local Game = class("Game")

function Game:initialize()
    self.card_images = AssetLoader:LoadAssets()
    self.draw_list = {}
    self:loadCenterCards()
    self.deck = Deck:new()
    self.deck:populate(self.card_images)
    self.players = {}
    self.hands = {}
    self.teamA = Team:new()
    self.teamB = Team:new()
    self.card_img_width = 64
    self.card_img_height = 64
    self.window_width = 1024
    self.window_height = 768

    local playerdecks = self.deck:distribute()
    local y = 100
    local xdiff = 100

    -- load team A
    for i = 1, (#playerdecks / 2), 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, 1)
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        self.teamA:addplayer(player.id)
    end

    y = self.window_height - 150
    -- load team B
    for i = 4, #playerdecks, 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * (i % 3)), y)
        local player = Player:new(hand, 1)
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        self.teamB:addplayer(player.id)
    end
end

function Game:loadCenterCards()
    local diamond08 = self.card_images["diamonds08"]
    local x, y = 300, 768 / 2
    table.insert(self.draw_list, { image = diamond08, x = x, y = y })

    x = 400
    local spades08 = self.card_images["spades08"]
    table.insert(self.draw_list, { image = spades08, x = x, y = y })

    x = 500
    local clubs08 = self.card_images["clubs08"]
    table.insert(self.draw_list, { image = clubs08, x = x, y = y })

    x = 600
    local hearts08 = self.card_images["hearts08"]
    table.insert(self.draw_list, { image = hearts08, x = x, y = y })
end

function Game:update(delta)
    for i = 1, #self.players, 1 do
        if self.players[i].isactive then
            self.players[i]:update()
        end
    end
end

function Game:click_event(x, y)
    for i = 1, #self.hands, 1 do
        if x > self.hands[i].batch_draw_x and x < self.hands[i].batch_draw_x + self.card_img_width
            and y > self.hands[i].batch_draw_y and y < self.hands[i].batch_draw_y + self.card_img_height
        then
            print("clicked a batch!!")
            self.hands[i]:reveal()
        end
    end
end

function Game:draw()
    for i = 1, #self.draw_list, 1 do
        love.graphics.draw(self.draw_list[i]["image"], self.draw_list[i]["x"],
            self.draw_list[i]["y"], 0, 1.5, 1.5)
    end
    for i = 1, #self.players, 1 do
        self.players[i]:draw()
    end
end

return Game
