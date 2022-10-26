package com.vnev.fish.Deck

enum class CardValue {
    TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE
}

enum class CardSuit {
    HEART, DIAMOND, CLUB, SPADE
}

enum class CardColor {
    RED, BLACK
}

data class Card(val value: CardValue, val suit: CardSuit) {
    val color = if (suit == CardSuit.HEART || suit == CardSuit.DIAMOND) CardColor.RED else CardColor.BLACK
}
