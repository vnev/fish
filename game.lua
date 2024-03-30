local love = require "love"
local class = require "middleclass"
local Team = require "team"
local Deck = require "deck"
local Hand = require "hand"
local Player = require "player"
local Utils = require "utils"
local AssetLoader = require "asset_loader"
local State = require "state"

local Game = class("Game")

function Game:loadSubdeckImages(card_images)
    local img = {}

    img["spades_low"] = {}
    img["spades_high"] = {}
    img["diamonds_low"] = {}
    img["diamonds_high"] = {}
    img["clubs_low"] = {}
    img["clubs_high"] = {}
    img["hearts_low"] = {}
    img["hearts_high"] = {}

    local suits = { "spades", "clubs", "diamonds", "hearts" }
    local low = { "02", "03", "04", "05", "06", "07" }
    local high = { "09", "10", "J", "Q", "K", "A" }

    for i = 1, #low, 1 do
        for j = 1, #suits, 1 do
            local key = suits[j] .. low[i]
            table.insert(img[suits[j] .. "_low"], card_images[key])
        end
    end

    for i = 1, #high, 1 do
        for j = 1, #suits, 1 do
            local key = suits[j] .. high[i]
            table.insert(img[suits[j] .. "_high"], card_images[key])
        end
    end

    return img
end

function Game:initialize()
    self.card_images = AssetLoader:LoadAssets()
    self.game_state = State:new()
    self.steal_list = {}
    self.draw_list = {}
    self.subdeck_images = self:loadSubdeckImages(self.card_images)
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
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * i), y)
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
    print('state: ' .. self.game_state.state)
    if self.game_state.state == self.game_state.StateType.PLAYING then
        self.game_state.state = self.game_state.StateType.PLAYER_STEALING
        -- draw the card picker
        local subdecks = {}
        local count = 0
        for i = 1, #self.active_player.hand.cards, 1 do
            print('player hand has: ' .. self.active_player.hand.cards[i].id)
            local key = self.active_player.hand.cards[i].suit .. "_" .. self.active_player.hand.cards[i].subdeck
            if subdecks[key] == nil then
                subdecks[key] = true
                count = count + 1
            end
        end
        local startx, starty = self.window_width / 2 - (50 * count), self.window_height / 2 - (55 * count)
        for k, _ in pairs(subdecks) do
            print('inserting ' .. k .. ' into steal list')
            for j = 1, #self.subdeck_images[k], 1 do
                table.insert(self.steal_list, { image = self.subdeck_images[k][j], x = startx, y = starty })
                startx = startx + 100
            end
            starty = starty + 50 + self.card_img_height
            startx = self.window_width / 2 - (50 * count)
        end
    elseif self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        -- TODO: player is stealing from other team, register click events as guesses
        -- based on which card is picked
        --
        -- after guessing, change state back to PLAYING after performing necessary updates
    end
    --[[for i = 1, #self.players, 1 do
        if self.players[i].teamid ~= self.active_team_id
        then
            if (x > self.players[i].hand.batch_draw_x) and (x < self.players[i].hand.batch_draw_x + self.card_img_width)
                and (y > self.players[i].hand.batch_draw_y) and (y < self.players[i].hand.batch_draw_y + self.card_img_height)
            then
                local guess_result = self:guess(self.players[i].hand, self.players[i].hand.cards[1])
                if not guess_result then
                    self.active_team_id = self.players[i].teamid
                    self.active_player = self.players[i]
                    return
                else
                    -- todo: active player keeps guessing
                end
            end
        end
    end--]]
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
    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 0.3)
    end

    for i = 1, #self.draw_list, 1 do
        love.graphics.draw(self.draw_list[i]["image"], self.draw_list[i]["x"],
            self.draw_list[i]["y"], 0, 1.5, 1.5)
    end

    for i = 1, #self.players, 1 do
        if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
            print("hand has " .. self.players[i].hand.batch:getCount())
            self.players[i].hand.batch:setColor(255, 255, 255, 0.3)
        end
        self.players[i]:draw()
    end

    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 1)
    end
    for i = 1, #self.steal_list, 1 do
        love.graphics.draw(self.steal_list[i]["image"], self.steal_list[i]["x"],
            self.steal_list[i]["y"], 0, 1.5, 1.5)
    end
end

return Game


--[[
deck.low_ranks = [2,3,4,5,6,7]
deck.high_ranks = [9,10,11,12,13,14]

player.hand = [7S, KH]
7S -> deck.low_ranks, spades
KH -> deck.high_ranks, hearts

cards_to_show = [loop through low_ranks, and spades, -> [2,3,4,5,6 SPADE],
                    loop though high_ranks, and hearts ->
    loop the n number of arrays created above and draw spritebatch
--]]
