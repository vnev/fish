--- cardPrefix_cardSuit_cardValue.cardFileExtension
local love = require "love"


local Assets = {}

local path_prefix = "assets/indiv_cards/"
local card_prefix = "card"
local card_suits = { "clubs", "diamonds", "hearts", "spades" }
local card_values = { "02", "03", "04", "05", "06", "07", "08", "09", "10", "J", "Q", "K", "A" }
local card_file_extension = ".png"

function Assets.LoadAssets()
    local cards = {} --- cardname -> lua.image

    cards["card_back"] = love.graphics.newImage(path_prefix .. card_prefix .. "_back" .. card_file_extension, {})
    for i = 1, #card_suits, 1
    do
        for j = 1, #card_values, 1
        do
            local filename = path_prefix ..
            card_prefix .. "_" .. card_suits[i] .. "_" .. card_values[j] .. card_file_extension
            local key = card_suits[i] .. card_values[j]
            cards[key] = love.graphics.newImage(filename, {})
        end
    end

    return cards
end

return Assets
