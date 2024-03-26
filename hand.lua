local class = require("middleclass")

local Hand = class("Hand")

function Hand:initialize(cards)
    self.cards = cards
    self.size = #cards
    self:updatesuits()
end

function Hand:add(card)
    self.cards:insert(card)
    self.size = #self.cards
end

function Hand:updatesuits()
    local suits = {}
    for i = 1, #self.cards, 1 do
        if not suits[self.cards[i]["suit"]] then
            suits[self.cards[i]["suit"]] = 1
        end
    end
    self.suits = suits
end

function Hand:remove(cardid)
    local idx = -1
    for i = 1, #self.cards, 1 do
        if self.cards[i]["id"] == cardid then
            idx = i
            break
        end
    end
    if idx > -1 then
        local removed = self.cards:remove(idx)
        self.size = #self.cards - 1
        self:updatesuits()
        return removed
    else
        print(cardid .. " was not found in this hand!")
        return nil
    end
end

return Hand
