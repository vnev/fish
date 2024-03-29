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
    print('teamA id ' .. self.teamA.id)
    self.teamB = Team:new()
    print('teamB id ' .. self.teamB.id)
    self.card_img_width = 64
    self.card_img_height = 64
    self.window_width = 1024
    self.window_height = 768
    self.active_player = {}
    self.active_team_id = -1

    local playerdecks = self.deck:distribute()
    local y = 100
    local xdiff = 100

    -- load team A
    for i = 1, (#playerdecks / 2), 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, self.teamA.id)
        print('player initialized: ' .. player.id)
        hand.belongs_to = player.id
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        self.teamA:addplayer(player.id)
    end

    self.active_player = self.players[1]
    self.active_team_id = self.teamA.id
    y = self.window_height - 150
    -- load team B
    for i = 4, #playerdecks, 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * (i)), y)
        local player = Player:new(hand, self.teamB.id)
        print('player initialized: ' .. player.id)
        hand.belongs_to = player.id
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
    for i = 1, #self.players, 1 do
        if self.players[i].teamid ~= self.active_team_id
        then
            if x > self.players[i].hand.batch_draw_x and (x < self.players[i].hand.batch_draw_x + self.card_img_width)
                and y > self.players[i].hand.batch_draw_y and (y < self.players[i].hand.batch_draw_y + self.card_img_height)
            then
                local guess_result = self:guess(self.players[i].hand, self.players[i].hand.cards[1])
                if not guess_result then
                    self.active_team_id = self.players[i].teamid
                    self.active_player = self.players[i]
                    return
                end
            end
        end
    end
end

function Game:guess(guessed_hand, guessed_card)
    for i = 1, #guessed_hand.cards, 1 do
        if guessed_card.id == guessed_hand.cards[i].id
        then
            for j = 1, #self.players, 1 do
                if guessed_hand.belongs_to == self.players[j].id
                then
                    local give_card = self.players[j]:give(guessed_card.id)
                    self.active_player:take(give_card)
                    return true
                end
            end
        end
    end
    return false
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
