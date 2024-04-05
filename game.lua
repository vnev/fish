local love = require "love"
local class = require "middleclass"
local Team = require "team"
local Deck = require "deck"
local Hand = require "hand"
local Player = require "player"
local AssetLoader = require "asset_loader"
local State = require "state"
require "noobhub/client/lua-love/noobhub"


local Game = class("Game")

function Game:initialize()
    self.client_id = math.random(1, 20)
    self.card_images = AssetLoader:LoadAssets()
    self.game_state = State:new()
    self.steal_list = {}
    self.draw_list = {}
    self:loadCenterCards()
    self.deck = Deck:new()
    self.connection = noobhub.new({ server = "127.0.0.1", port = 1337 })
    print('established connection to server')

    self.deck:populate(self.card_images)
    self.font = love.graphics.newFont("Workbench.ttf", 16)
    print("loaded font workbench, dpi scale: " .. self.font:getDPIScale())
    self.players = {}
    self.hands = {}
    self.teamA = Team:new(1, self.card_images["card_back"])
    self.teamB = Team:new(2, self.card_images["card_back"])
    self.card_img_width = 64
    self.card_img_height = 64
    self.window_width = 1024
    self.window_height = 850
    self.active_player = {}
    self.active_team_id = -1

    self.connection:subscribe({
        channel = "fish0",
        callback = function(message)
            print(message.clientid)
        end,
    })

    local playerdecks = self.deck:distribute()

    -- load team A
    for i = 1, (#playerdecks / 2), 1 do
        local hand = Hand:new(playerdecks[i], i)
        local player = Player:new(i, hand, self.teamA)
        player:updatestealable(self.deck.cards)
        table.insert(self.hands, hand)
        table.insert(self.players, player)
        print('adding player ' .. player.id .. ' to ' .. self.teamA.id)
        self.teamA:addplayer(player)
    end

    self.active_player = self.players[1]
    self.stealing_from = nil
    -- load team B
    for i = 4, #playerdecks, 1 do
        local hand = Hand:new(playerdecks[i], i)
        local player = Player:new(i, hand, self.teamB)
        player:updatestealable(self.deck.cards)
        table.insert(self.hands, hand)
        table.insert(self.players, player)

        print('adding player ' .. player.id .. ' to ' .. self.teamB.id)
        self.teamB:addplayer(player)
    end
    -- TODO: remove in the future, for testing single-player mode
    self.players[1].isstealing = true
    self.teamA.isstealing = true

    print("connection is: ")
    print(self.connection)
end

function Game:loadCenterCards()
    local diamond08 = self.card_images["diamonds08"]
    local x, y = 300, 768 / 2 - 125
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

    self.teamA:update()
    self.teamB:update()
    self.connection:publish({
        message = {
            clientid = self.client_id
        }
    })
end

function Game:click_event(x, y)
    print('state: ' .. self.game_state.state)

    local text = love.graphics.newText(self.font,
        "Player " .. self.active_player.id .. " is stealing")
    love.graphics.draw(text, 400, 300, 0, 1, 1)

    if self.game_state.state == self.game_state.StateType.PLAYING then
        local team
        if self.active_player.team == self.teamA then team = self.teamA else team = self.teamB end

        for i = 1, #team.players, 1 do
            local player = team.players[i]
            if (x >= team.card_batches[i].x) and (x <= team.card_batches[i].x + self.card_img_width)
                and (y >= team.card_batches[i].y) and (y <= team.card_batches[i].y + self.card_img_height)
            then
                print(self.active_player.id .. ' clicked on ' .. player.id)
                self.stealing_from = player
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
            self.active_player.isstealing = false
            self.active_player.team.isstealing = false
            self.active_player = self.stealing_from
            self.active_player.isstealing = true
            self.active_player.team.isstealing = true
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
        love.graphics.setColor(255, 255, 255, 0.15)
    end

    for i = 1, #self.draw_list, 1 do
        love.graphics.draw(self.draw_list[i].image, self.draw_list[i].x,
            self.draw_list[i].y, 0, 1.5, 1.5)
    end

    for i = 1, #self.players, 1 do
        self.players[i]:draw()
    end

    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        local team = self.stealing_from.team
        for i = 1, #team.card_batches, 1 do
            team.card_batches[i].batch:setColor(255, 255, 255, 0.15)
        end
    end
    self.teamA:draw()
    self.teamB:draw()

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
