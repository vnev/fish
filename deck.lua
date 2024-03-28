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

    local tbl = { [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A" }

    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local img_key = suit
            if rank >= 10 then
                img_key = img_key .. tbl[rank]
            else
                img_key = img_key .. '0' .. rank
            end
            local card = Card:new(suit, rank, cardimages[img_key])
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

local function copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Deck:distribute()
    -- distribute 8 cards to the 6 players
    -- maybe shuffle after every 8 cards are pulled?
    local playerdecks = {}
    self:shuffle()
    local cardscopy = copy(self.cards)

    -- TODO: figure out why I have to do the last copy separately
    for i = 1, 5, 1 do
        local currdeck = {}
        for j = 1, 8, 1 do
            local newcard = table.remove(cardscopy, j)
            table.insert(currdeck, newcard)
        end
        playerdecks[i] = currdeck
    end
    playerdecks[6] = cardscopy

    print("playerdecks: " .. #playerdecks .. ", cards: " .. #self.cards)
    return playerdecks
end

return Deck
