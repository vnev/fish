local love = require "love"
local AssetLoader = require "asset_loader"
local cardimages = {}

local imagesToDraw = {}

function love.load()
    local window_width = 1024
    local window_height = 768

    love.window.setMode(window_width, window_height, { fullscreen = false })
    cardimages = AssetLoader:LoadAssets()["cards"]

    LoadCenterCards()
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
        love.graphics.draw(imagesToDraw[i]["image"], imagesToDraw[i]["x"], imagesToDraw[i]["y"])
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
