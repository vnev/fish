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

function Game:initialize()
    self.card_images = AssetLoader:LoadAssets()
    self.game_state = State:new()
    self.steal_list = {}
    self.draw_list = {}
    self:loadCenterCards()
    self.deck = Deck:new()
    self.deck:populate(self.card_images)
    self.players = {}
    self.hands = {}
    self.teamA = Team:new()
    self.teamA.id = 1
    self.teamB = Team:new()
    self.teamB.id = 2
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
    local playerid = 1
    for i = 1, (#playerdecks / 2), 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, self.teamA.id)
        player.id = playerid
        playerid = playerid + 1
        player:updatestealable(self.deck.cards)
        hand.belongs_to = player.id
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        print('adding player ' .. player.id .. ' to ' .. self.teamA.id)
        self.teamA:addplayer(player.id)
    end

    self.active_player = self.players[1]
    self.stealing_from = nil
    y = self.window_height - 150
    -- load team B
    for i = 4, #playerdecks, 1 do
        local hand = Hand:new(playerdecks[i], self.card_images["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, self.teamB.id)
        player.id = playerid
        playerid = playerid + 1
        player:updatestealable(self.deck.cards)
        hand.belongs_to = player.id
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        print('adding player ' .. player.id .. ' to ' .. self.teamB.id)
        self.teamB:addplayer(player.id)
    end
end

function Game:loadCenterCards()
    local diamond08 = self.card_images["diamonds08"]
    local x, y = 300, 768 / 2 - 50
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
        self.players[i]:update()
        self.players[i]:updatestealable(self.deck.cards)
    end
end

function Game:click_event(x, y)
    print('state: ' .. self.game_state.state)

    if self.game_state.state == self.game_state.StateType.PLAYING then
        for i = 1, #self.players, 1 do
            if self.players[i].teamid ~= self.active_player.teamid then
                if (x >= self.players[i].hand.batch_draw_x) and (x <= self.players[i].hand.batch_draw_x + self.card_img_width)
                    and (y >= self.players[i].hand.batch_draw_y) and (y <= self.players[i].hand.batch_draw_y + self.card_img_height)
                then
                    print(self.active_player.id .. ' clicked on ' .. self.players[i].id)
                    self.stealing_from = self.players[i]
                    self.game_state.state = self.game_state.StateType.PLAYER_STEALING
                    local subdecks = self.active_player.stealable
                    local count = 0
                    for _, _ in pairs(subdecks) do
                        count = count + 1
                    end
                    local startx, starty = self.window_width / 2 - (50 * count), self.window_height / 2 - (54 * count)
                    for k, v in pairs(subdecks) do
                        print("adding " .. #v .. " images for " .. k .. " to the steal list")
                        if #v > 0 then
                            for j = 1, #v, 1 do
                                table.insert(self.steal_list, { card = v[j], x = startx, y = starty })
                                startx = startx + 100
                            end
                            starty = starty + 50 + self.card_img_height
                            startx = self.window_width / 2 - (50 * count)
                        end
                    end
                end
            end
        end
        -- draw the card picker
    elseif self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        -- TODO: player is stealing from other team, register click events as guesses
        -- based on which card is picked
        --
        -- after guessing, change state back to PLAYING after performing necessary updates
        local stolen = false
        for i = 1, #self.steal_list, 1 do
            if (x >= self.steal_list[i].x) and (x <= self.steal_list[i].x + self.card_img_width)
                and (y >= self.steal_list[i].y) and (y <= self.steal_list[i].y + self.card_img_height)
            then
                -- currently trying to steal self.steal_list[i].card
                for j = 1, #self.stealing_from.hand.cards, 1 do
                    if self.stealing_from.hand.cards[j].id == self.steal_list[i].card.id then
                        local stolen_card = self.stealing_from:give(self.stealing_from.hand.cards[j].id)
                        self.active_player:take(stolen_card)
                        print(self.active_player.id .. ' stole ' .. stolen_card.readable_id)
                        stolen = true
                        break
                    end
                end
                if stolen then
                    break
                end
            end
        end
        if not stolen then
            print('switching active player... current: ' .. self.active_player.id)
            self.active_player = self.stealing_from
            print('switching active player... new: ' .. self.active_player.id)
        end
        self.stealing_from = nil
        self.game_state.state = self.game_state.StateType.PLAYING
        self.steal_list = {}
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
    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 0.3)
    end

    for i = 1, #self.draw_list, 1 do
        love.graphics.draw(self.draw_list[i].image, self.draw_list[i].x,
            self.draw_list[i].y, 0, 1.5, 1.5)
    end

    for i = 1, #self.players, 1 do
        if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
            self.players[i].hand.batch:setColor(255, 255, 255, 0.3)
        end
        self.players[i]:draw()
    end

    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 1)
    end
    for i = 1, #self.steal_list, 1 do
        love.graphics.draw(self.steal_list[i].card.image, self.steal_list[i].x,
            self.steal_list[i].y, 0, 1.5, 1.5)
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
