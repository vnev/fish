local class = require "middleclass"
local math = require "math"
local Utils = require "utils"
local Player = class("Player")

function Player:initialize(hand, teamid)
    self.hand = hand
    self.teamid = teamid
    self.id = math.random()
    self.isactive = true
    self.stealable = {}
end

function Player:updatestealable(all_cards)
    self.stealable = {}

    for i = 1, #self.hand.cards, 1 do
        if self.stealable[self.hand.cards[i].suit .. '_' .. self.hand.cards[i].subdeck] == nil then
            self.stealable[self.hand.cards[i].suit .. '_' .. self.hand.cards[i].subdeck] = {}
        end
    end

    for i = 1, #all_cards, 1 do
        local found = false
        for j = 1, #self.hand.cards, 1 do
            if self.hand.cards[j].suit == all_cards[i].suit and
                self.hand.cards[j].subdeck == all_cards[i].subdeck and
                all_cards[i].id ~= self.hand.cards[j].id
            then
                print('adding card id to stealable: ' .. all_cards[i].id)
                found = true
                break
            end
        end

        if found then
            if self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck] == nil then
                self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck] = {}
            end
            table.insert(self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck],
                Utils:copyarr_shallow(all_cards[i]))
        end
    end
end

function Player:update()
    self.hand:update()
end

function Player:draw()
    self.hand:draw()
end

function Player:give(cardid)
    -- give from our deck
    local res = self.hand:remove(cardid)
    if self.hand:count() == 0 then
        self.isactive = false
    end
    return res
end

function Player:take(card)
    -- add to our deck
    self.hand:add(card)
end

return Player
