local class = require 'middleclass'

local Card = class('Card')

function Card:initialize(suit, rank, image)
    self.suit = suit
    self.rank = rank
    self.id = suit .. rank
    if self.rank <= 7 then self.subdeck = 'low' else self.subdeck = 'high' end
    self.image = image -- TODO: populate
end

function Card:__tostring()
    return self.rank .. " of " .. self.suit
end

return Card
