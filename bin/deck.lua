local Desk = class('Deck')

function Deck:initalize()
    self:cards = {}
    self:populate()
end

function Deck:populate()
    local suits = {'hearts', 'diamonds', 'clubs', 'spades'}
    local rank = {'A','2','3', '4', '5', '6', '7', '9', '1', 'J', 'Q', 'K'}
    local value = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}

    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            for _, value in ipairs(value) do
                table.insert(self.cards, Card:new(suit,rank,value))
            end
        end
    end
end


function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end
