local class = require "middleclass"
local love = require "love"

local Hand = class("Hand")


function Hand:initialize(cards, belongs_to)
    self.cards = cards
    self.belongs_to = belongs_to -- player ID
    self.subdecks = {}
    self.numsubdecks = 0
    self:update()
end

function Hand:update()
    self:updatesubdecks()
end

function Hand:draw()
end

function Hand:add(card)
    table.insert(self.cards, card)
end

function Hand:updatesubdecks()
    self.numsubdecks = 0
    self.subdecks = {}

    for i = 1, #self.cards, 1 do
        local card = self.cards[i]
        if self.subdecks[card.suit .. card.subdeck] == nil then
            self.numsubdecks = self.numsubdecks + 1
            self.subdecks[card.suit .. card.subdeck] = {}
        end
        table.insert(self.subdecks[card.suit .. card.subdeck], card)
    end
end

function Hand:count()
    return #self.cards
end

function Hand:remove(cardid)
    local idx = -1
    for i = 1, #self.cards, 1 do
        if self.cards[i].id == cardid then
            idx = i
            break
        end
    end
    if idx > -1 then
        local removed = table.remove(self.cards, idx)
        self:updatesuits() -- TODO: do we need this, update() should be called anyway
        return removed
    else
        return nil
    end
end

return Hand
