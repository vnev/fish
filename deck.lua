local class = require("middleclass")
local Card = require("Card")
local Deck = class('Deck')

function Deck:initialize()
    self.cards = {}
end

-- Deck is 2-7 (low cards) and 9-A (high cards)
function Deck:populate(cardimages)
    local suits = { 'hearts', 'diamonds', 'clubs', 'spades' }
    local ranks = { 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14 }

    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local img_key = suit
            if rank >= 10 then
                local tbl = { [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A" }
                img_key = img_key .. tbl[rank]
            else
                img_key = img_key .. '0' .. rank
            end
            local card = Card
            card:initialize(suit, rank, cardimages[img_key])
            print('adding ' .. card.id)
            table.insert(self.cards, card)
        end
    end

    self:shuffle()
    print('populated ' .. #self.cards .. ' cards')
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
    for i = 1, 6, 1 do
        self:shuffle()
        local currdeck = {}
        for j = 1, 8, 1 do
            print(self.cards[j].id) -- TODO: what the fuck is this bug
            local newcard = table.remove(self.cards, j)
            table.insert(currdeck, newcard)
        end
        playerdecks[i] = currdeck
    end

    return playerdecks
end

return Deck
