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
    self.card_images = AssetLoader:LoadAssets()
    self.game_state = State:new() -- state starts as StateType.CONNECTING, click events will not register till all 6 players have connected
    self.game_state.state = self.game_state.StateType.JOINING_GAME
    self.steal_list = {}
    self.draw_list = {}
    self:loadCenterCards()
    self.deck = Deck:new()
    self.deck:populate(self.card_images)
    self.connection = noobhub.new({ server = "127.0.0.1", port = 1337 })
    if not self.connection then
        error("failed to connect to Noob")
    end
    print('established connection to server')

    self.font = love.graphics.newFont("Workbench.ttf", 16)
    self.teamA = Team:new(0, self.card_images["card_back"])
    self.teamB = Team:new(1, self.card_images["card_back"])
    self.card_img_width = 64
    self.card_img_height = 64
    self.window_width = 1024
    self.window_height = 850
    self.player = {}
    self.stealing_from = nil

    local function cb(message)
        local hand = {}
        if message.join_code then
            print('join code: ' .. message.join_code)
        end
        if message.hand then
            hand = Hand:new(self.deck:from(message.hand), -1)
        end
        if message.player_id and message.team then
            assert(hand)
            local team
            if message.team == 0 then
                team = self.teamA
            else
                team = self.teamB
            end
            self.player = Player:new(message.player_id, hand, team)
            hand.belongs_to = self.player.id
            print('Creating new player with ID: ' .. self.player.id .. ' belonging to team: ' .. team.id)
            team:addplayer(self.player.id)
            love.window.setTitle("Fish " .. self.player.id)
        end
        if message.active_player_id then
            if message.active_player_id == self.player.id then
                print('setting active client to this client')
                self.player.isstealing = true
                if message.status == 'switch' then
                    print('switching to playing state!')
                    self.game_state.state = self.game_state.StateType.PLAYING
                end
            else
                print('active client is currently: ' .. message.active_player_id)
                self.player.isstealing = false
            end
        end
        if message.status == 'begin_game' then
            print('starting game')
            for k, v in pairs(message.teams) do
                local team
                local s
                if k == '0' then
                    team = self.teamA
                    s = 'teamA'
                else
                    team = self.teamB
                    s = 'teamB'
                end
                for i = 1, #v, 1 do
                    if v[i] ~= self.player.id then
                        print('adding ' .. v[i] .. ' to ' .. s)
                        team:addplayer(v[i])
                    end
                end
            end
            if message.active_player_id == self.player.id then
                self.game_state.state = self.game_state.StateType.PLAYING
                print('i am ready to play!')
            else
                self.game_state.state = self.game_state.StateType.IDLING
            end
        end
        if message.status == 'steal' then
            if message.result == 'success' then
                local stolen_card_id = message.stolen_card_id
                print('You successfully stole ' .. message.stolen_card_id)
                local card = self.deck:getcardbyid(stolen_card_id)
                assert(card)
                self.player.hand:add(card)
                self.game_state.state = self.game_state.StateType.PLAYING
            else
                print('Steal failed, switching players...')
                self.game_state.state = self.game_state.StateType.IDLING
            end
            self.stealing_from = nil
        end
        if message.status == 'drop_card' then
            local found_idx = -1
            for i = 1, #self.player.hand.cards, 1 do
                if self.player.hand.cards[i].id == message.stolen_card_id then
                    found_idx = i
                    break
                end
            end
            table.remove(self.player.hand.cards, found_idx)
            print('removed ' .. message.stolen_card_id .. ' from player hand')
        end
        if message.hand then
            print('player hand: ')
            for i = 1, #message.hand, 1 do
                print(message.hand[i])
            end
        end
    end

    if self.game_state.state == self.game_state.StateType.CREATING_GAME then
        self.connection:registerchannel({
            callback = cb
        })
    elseif self.game_state.state == self.game_state.StateType.JOINING_GAME then
        self.connection:subscribe({
            channel = 'aUZdw',
            callback = cb
        })
    end
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
    self.connection:enterFrame()
    self.player:update()
    self.player:updatestealable(self.deck.cards)

    self.teamA:update()
    self.teamB:update()
end

function Game:click_event(x, y)
    print('state: ' .. self.game_state.state)

    local text = love.graphics.newText(self.font,
        "Player " .. self.player.id .. " is stealing")
    love.graphics.draw(text, 400, 300, 0, 1, 1)

    if self.game_state.state == self.game_state.StateType.CONNECTING or
        self.game_state.state == self.game_state.StateType.CREATING_GAME or
        self.game_state.state == self.game_state.StateType.JOINING_GAME or
        self.game_state.state == self.game_state.StateType.IDLING then
        -- dont do anything
    elseif self.game_state.state == self.game_state.StateType.PLAYING then
        local team
        if self.player.team == self.teamA then team = self.teamB else team = self.teamA end
        for i = 1, #team.players, 1 do
            local player = team.players[i]
            if (x >= team.card_batches[i].x) and (x <= team.card_batches[i].x + self.card_img_width)
                and (y >= team.card_batches[i].y) and (y <= team.card_batches[i].y + self.card_img_height)
            then
                print(self.player.id .. ' clicked on ' .. player)
                self.stealing_from = player
                self.game_state.state = self.game_state.StateType.PLAYER_STEALING
                local subdecks = self.player.stealable
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
                self.connection:trysteal(self.player.id, self.stealing_from, self.steal_list[i].card.id)
                -- do this so user can't perform any more click actions until server gets back with the result
                self.game_state.state = self.game_state.StateType.IDLING
                break
            else
                -- user clicked outside, so just reset state
                self.game_state.state = self.game_state.StateType.PLAYING
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
    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 0.15)
    end

    for i = 1, #self.draw_list, 1 do
        love.graphics.draw(self.draw_list[i].image, self.draw_list[i].x,
            self.draw_list[i].y, 0, 1.5, 1.5)
    end

    self.player:draw()

    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        local team
        if self.player.team == self.teamA then team = self.teamB else team = self.teamA end
        for i = 1, #team.card_batches, 1 do
            team.card_batches[i].batch:setColor(255, 255, 255, 0.15)
        end
    end

    if self.player.team.id == self.teamA.id then
        self.teamB:draw()
    else
        self.teamA:draw()
    end

    if self.game_state.state == self.game_state.StateType.PLAYER_STEALING then
        love.graphics.setColor(255, 255, 255, 1)

        for i = 1, #self.steal_list, 1 do
            love.graphics.draw(self.steal_list[i].card.image, self.steal_list[i].x,
                self.steal_list[i].y, 0, 1.5, 1.5)
        end
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
