package com.vnev.fish.Player

import com.vnev.fish.Deck.Card
import java.util.*

data class Player(val name: String, private val hand: Hand = Hand()) {
    val id: String = UUID.randomUUID().toString()

    fun guess(card: Card): Boolean {
        val wasRemoved = hand.removeIfContains(card)
        // add to guesser's hand
    }
}

class Hand {
    private val hand: MutableList<Card> = mutableListOf()

    fun addToHand(card: Card) {
        hand.add(card)
    }

    fun removeIfContains(cardToRemove: Card): Boolean {
        return hand.removeAll { card -> card == cardToRemove }
    }

    fun containsCard(card: Card): Boolean {
        return hand.contains(card)
    }
}
