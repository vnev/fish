local class = require 'middleclass'

local Card = class('Card')

function Card:initialize(suit, rank, value, sub)
    self.suit = suit
    self.rank = rank
    self.id = suit .. rank
    self.value = value
    self.subdeck = suit .. '_' .. sub
end

function Card:__tostring()
    return self.rank .. " of " .. self.suit
end

return Card
