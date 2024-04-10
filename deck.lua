local class = require("middleclass")
local Card = require("Card")
local Utils = require("utils")

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
            table.insert(self.cards, card)
        end
    end

    self:shuffle()
    print('populated ' .. #self.cards .. ' cards')
end

function Deck:shuffle()
    for i = #self.cards, 1, -1 do
        -- terrible attempt at getting enough randomness for the shuffle
        -- should be fine since we only do this at the start of the game
        -- but maybe we should find a better way?
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:from(cards)
    self:shuffle()
    local cardscopy = Utils:copyarr_shallow(self.cards)

    -- TODO: figure out why I have to do the last copy separately
    local currdeck = {}
    for j = 1, #cards, 1 do
        local newcard = {}
        for x = 1, #cardscopy, 1 do
            if cardscopy[x].id == cards[j] then
                newcard = table.remove(cardscopy, x)
                break
            end
        end
        assert(newcard)
        table.insert(currdeck, newcard)
    end

    return currdeck
end

return Deck
