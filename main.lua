local love = require "love"
local Deck = require "deck"
local Player = require "player"
local Team = require "team"
local Hand = require "hand"

local AssetLoader = require "asset_loader"

local cardimages = {}
local imagesToDraw = {}

function Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. Dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local players = {}
local hands = {}
local teamA = Team:new()
local teamB = Team:new()
local cardwidth = 64

function love.load()
    print('loading')
    local window_width = 1024
    local window_height = 768

    love.window.setMode(window_width, window_height, { fullscreen = false })
    cardimages = AssetLoader:LoadAssets()
    LoadCenterCards()
    local deck = Deck:new()
    deck:populate(cardimages)
    local playerdecks = deck:distribute()
    assert(#playerdecks == 6)

    local y = 100
    local xdiff = 100
    -- load team A
    for i = 1, 3, 1 do
        local hand = Hand:new(playerdecks[i], cardimages["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, 1)
        table.insert(hands, hand)
        table.insert(players, player)
        teamA:addplayer(player.id)
    end

    y = window_height - 150
    -- load team B
    for i = 4, #playerdecks, 1 do
        local hand = Hand:new(playerdecks[i], cardimages["card_back"], 200 + (xdiff * i), y)
        local player = Player:new(hand, 1)
        table.insert(hands, hand)
        table.insert(players, player)
        teamB:addplayer(player.id)
    end
    -- initialize order
    --      Deck (which will init the cards)
    --          Players
    --              Hands
    --                  Team
    --                      ...
end

function LoadCenterCards()
    local diamond08 = cardimages["diamonds08"]
    local x, y = 300, 768 / 2
    table.insert(imagesToDraw, { image = diamond08, x = x, y = y })

    x = 400
    local spades08 = cardimages["spades08"]
    table.insert(imagesToDraw, { image = spades08, x = x, y = y })

    x = 500
    local clubs08 = cardimages["clubs08"]
    table.insert(imagesToDraw, { image = clubs08, x = x, y = y })

    x = 600
    local hearts08 = cardimages["hearts08"]
    table.insert(imagesToDraw, { image = hearts08, x = x, y = y })
    print("num imagesToDraw: " .. #imagesToDraw)
end

function love.draw()
    for i = 1, #imagesToDraw, 1
    do
        love.graphics.draw(imagesToDraw[i]["image"], imagesToDraw[i]["x"], imagesToDraw[i]["y"], 0, 1.5, 1.5)
    end
    for i = 1, #players, 1 do
        players[i]:draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for i = 1, #hands, 1 do
            if x > hands[i].batch_draw_x and x < hands[i].batch_draw_x + cardwidth and y > hands[i].batch_draw_y and y < hands[i].batch_draw_y + cardwidth then
                print("clicked a batch!!")
                -- hands[i]:reveal()
            end
        end
    end
end

function love.update(delta)
    for i = 1, #players, 1 do
        players[i]:update()
    end
end

function Main()
    local deck = Deck:new()
    deck:shuffle()
    for _, card in ipairs(deck.cards) do
        print(tostring(card))
    end
end

Main()
