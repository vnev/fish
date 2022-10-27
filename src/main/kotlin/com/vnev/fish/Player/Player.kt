package com.vnev.fish.Player

import com.vnev.fish.Deck.Card
import java.util.*

data class Player(val name: String, private val hand: Hand = Hand()) {
    val id: String = UUID.randomUUID().toString()
        // add to guesser's hand
        if(hand.contains(card)){
            player.addToHand(card);
        }

        //remove from player's hand
        val wasRemoved = hand.removeIfContains(card)
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
