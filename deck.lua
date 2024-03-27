local class = require("middleclass")
local Card = require("Card")
local Deck = class('Deck')

function Deck:initialize()
    self.cards = {}
    self:populate()
end

-- Deck is 2-7 (low cards) and 9-A (high cards)
function Deck:populate()
    local suits = { 'hearts', 'diamonds', 'clubs', 'spades' }
    local ranks = { 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14 }

    for _, suit in ipairs(suits) do
        for i, rank in ipairs(ranks) do
            self.cards:insert(Card:new(suit, rank))
        end
    end
end

function Deck:shuffle()
    for i = #self.cards, 1, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:distribute()
    -- distribute 8 cards to the 6 players
    -- maybe shuffle after every 8 cards are pulled?
    local playerdecks = {}
    self:shuffle()

end

return Deck
