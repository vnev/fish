local class = require "middleclass"
local love = require "love"

local Hand = class("Hand")


function Hand:initialize(cards, batch_img, batch_x, batch_y)
    self.cards = cards
    self.batch = love.graphics.newSpriteBatch(batch_img, #cards)
    self.batch_draw_x = batch_x
    self.batch_draw_y = batch_y
    self.belongs_to = -100
end

function Hand:update()
    self:updatesuits()
    self:updatebatch()
end

function Hand:draw()
    self:updatebatch() -- TODO: this is a hack to make sure the alpha channel on the spritebatch images are updated, find a better way?
    love.graphics.draw(self.batch, 0, 0)
    self.batch:flush()
end

function Hand:updatebatch()
    self.batch:clear()

    local rotate = 0.0
    for i = 1, #self.cards, 1 do
        self.batch:add(self.batch_draw_x, self.batch_draw_y, rotate, 1.5, 1.5)
        rotate = rotate + 0.01
    end
end

function Hand:add(card)
    table.insert(self.cards, card)
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
