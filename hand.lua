local class = require "middleclass"
local love = require "love"

local Hand = class("Hand")


function Hand:initialize(cards, belongs_to)
    self.cards = cards
    self.belongs_to = belongs_to -- player ID
end

function Hand:update()
    self:updatesuits()
end

function Hand:draw()
    self:updatebatch() -- TODO: this is a hack to make sure the alpha channel on the spritebatch images are updated, find a better way?
    self.batch:flush()
end

function Hand:add(card)
    table.insert(self.cards, card)
end

function Hand:updatesuits()
    local suits = {}
    for i = 1, #self.cards, 1 do
        if not suits[self.cards[i].suit] then
            suits[self.cards[i].suit] = 1
        end
    end
    self.suits = suits
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
