local class = require "middleclass"
local Utils = require "utils"
local love = require "love"
local Player = class("Player")

function Player:initialize(playerid, hand, team)
    self.hand = hand
    self.team = team
    self.id = playerid
    self.isactive = true
    self.stealable = {}
    self.isstealing = false
end

-- ["suit_low/high": { card1, card2, card3}]
function Player:updatestealable(all_cards)
    self.stealable = {}

    for i = 1, #self.hand.cards, 1 do
        if self.stealable[self.hand.cards[i].suit .. '_' .. self.hand.cards[i].subdeck] == nil then
            self.stealable[self.hand.cards[i].suit .. '_' .. self.hand.cards[i].subdeck] = {}
        end
    end

    -- TODO: INSANELY FUCKING UGLY, REFACTOR IMMEDIATELY
    -- REFACTOR TO CREATE 1 FULL SET OF ALL SUBDECKS
    -- THEN REMOVE CARDS IN HAND
    for i = 1, #all_cards, 1 do
        local found = false
        local tracker = {}
        for j = 1, #self.hand.cards, 1 do
            if self.hand.cards[j].suit == all_cards[i].suit and
                self.hand.cards[j].subdeck == all_cards[i].subdeck
            then
                if self.hand.cards[j].id == all_cards[i].id then
                elseif tracker[all_cards[i].id] == nil then
                    if self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck] == nil then
                        self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck] = {}
                    end
                    table.insert(self.stealable[all_cards[i].suit .. '_' .. all_cards[i].subdeck],
                        Utils:copyarr_shallow(all_cards[i]))
                    tracker[all_cards[i].id] = true
                else
                end
            end
        end

        for _, v in pairs(self.stealable) do
            for j = 1, #v, 1 do
                for k = 1, #self.hand.cards, 1 do
                    if self.hand.cards[k].id == v[j].id then
                        table.remove(v, j)
                        break
                    end
                end
            end
        end
    end
end

function Player:update()
    self.hand:update()
end

function Player:draw()
    -- this is a hack to only show player 1 hand on the bottom row, when doing multiplayer we need to remove the isstealing condition
    if not self.isactive and not self.isstealing then
        return
    end

    local draw_at_x, draw_at_y = 110, 650
    local playerhand = self.hand
    for i = 1, #playerhand.cards, 1 do
        love.graphics.draw(playerhand.cards[i].image, draw_at_x, draw_at_y, 0, 1.5, 1.5)
        draw_at_x = draw_at_x + 100
    end
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
