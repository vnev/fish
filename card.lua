local class = require 'middleclass'
local love = require 'love'
local AssetLoader = require "asset_loader"

local Card = class('Card')

function Card:initialize(suit, rank, value, sub)
    self.suit = suit
    self.rank = rank
    self.id = suit .. rank
    self.value = value
    self.subdeck = suit .. '_' .. sub
end

function Card:draw(x, y, cardimages)
    local image = cardimages[self.id]
    if image then
        love.graphics.draw(image, x, y)
    end
end

function Card:update()
end

function Card:__tostring()
    return self.rank .. " of " .. self.suit
end

return Card
