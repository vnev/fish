local class = require("middleclass")
local Card = require("Card")
local Deck = class('Deck')

function Deck:initialize()
    self.cards = {}
    self:populate()
end

function Deck:populate()
    local suits = { 'hearts', 'diamonds', 'clubs', 'spades' }
    local ranks = { 'A', '2', '3', '4', '5', '6', '7', '9', '10', 'J', 'Q', 'K' }
    local value = { 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13 }
    local subdecks = { 'low', 'low', 'low', 'low', 'low', 'low', 'low',
        'high', 'high', 'high', 'high', 'high' }

    for _, suit in ipairs(suits) do
        for i, rank in ipairs(ranks) do
            local val = value[i]
            local sub = subdecks[i]
            table.insert(self.cards, Card:new(suit, rank, val, sub))
        end
    end
end

function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

return Deck
