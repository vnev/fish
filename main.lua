local love = require "love"

local AssetLoader = require "asset_loader"
local cardimages = {}

local imagesToDraw = {}
local faceDownDecks = {} --- holds face down decks to be drawn

function Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function love.load()
    local window_width = 1024
    local window_height = 768

    love.window.setMode(window_width, window_height, { fullscreen = false })
    cardimages = AssetLoader:LoadAssets()["cards"]
    LoadCenterCards()
    LoadPlayerDecks(3)
end

function LoadPlayerDecks(numDeckPairs)
    local w, h = 1024, 768
    local yBot = h - 200
    local yTop = 200
    local x = 250
    local rotateFactor = 0.0 -- go up to 0.2 radians
    for i = 1, numDeckPairs, 1
        do
            local tmp = love.graphics.newSpriteBatch(cardimages["card_back"], 8)
            local tmp2 = love.graphics.newSpriteBatch(cardimages["card_back"], 8)
        for i = 1, 8, 1
            do
            tmp:add(x, yBot, rotateFactor, 1.5, 1.5)
            tmp2:add(x, yTop, rotateFactor, 1.5, 1.5)
            rotateFactor = rotateFactor + 0.02
        end
        table.insert(faceDownDecks, tmp)
        table.insert(faceDownDecks, tmp2)
        x = x + 200
        rotateFactor = 0.0
    end
end

function LoadCenterCards()
    local diamond08 = cardimages["diamonds08"]
    local x, y = 300, 768/2
    table.insert(imagesToDraw, { image = diamond08,  x = x, y = y })

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
    for i = 1, #faceDownDecks, 1 do -- should be 6
        love.graphics.draw(faceDownDecks[i], 0, 0)
    end
end

function love.update(delta)
    if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        for i = 1, #imagesToDraw, 1
        do
            imagesToDraw[i]["x"] = mx
            mx = mx + imagesToDraw[i]["image"]:getWidth() * 2
            imagesToDraw[i]["y"] = my ---v+ imagesToDraw[i]["image"]:getHeight()
        end
    end
end
