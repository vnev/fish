local love = require "love"
local Game = require "game"

local game

function love.load()
    math.randomseed(os.time())
    print('loading')
    game = Game:new()
    love.window.setTitle("Fish")
    love.window.setMode(game.window_width, game.window_height, { fullscreen = false })
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        game:click_event(x, y)
    end
end

function love.update(delta)
    game:update(delta)
end
