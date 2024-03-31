local class = require 'middleclass'

local Card = class('Card')

function Card:initialize(suit, rank, image)
    self.suit = suit
    self.rank = rank
    self.id = suit .. rank
    if self.rank <= 7 then self.subdeck = 'low' else self.subdeck = 'high' end
    self.image = image
    self.readable_id = self.suit
    local tbl = { [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A" }
    if self.rank >= 10 then
        self.readable_id = self.readable_id .. tbl[self.rank]
    else
        self.readable_id = self.readable_id .. '0' .. self.rank
    end
end

function Card:__tostring()
    return self.rank .. " of " .. self.suit
end

return Card
