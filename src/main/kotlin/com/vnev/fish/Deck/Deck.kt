package com.vnev.fish.Deck

import kotlin.random.Random

class Deck() {
    private val DECK_SIZE = 48 // 52 minus four 8-value cards
    private val AVOID_CARD = CardValue.EIGHT

    private var deck: MutableList<Card> = mutableListOf()

    init {
        enumValues<CardSuit>().forEach { suit ->
            enumValues<CardValue>().forEach { value ->
                if (value != AVOID_CARD) {
                    deck.add(Card(value, suit))
                }
            }
        }
        println("DECK INITIALIZED")
        println("LENGTH IS CORRECT? ${deck.size == DECK_SIZE}")
        shuffleDeck()
    }

    private fun shuffleDeck() {
        println("DECK SHUFFLED")
        deck.shuffle(Random(Random.nextLong()))
    }

    fun split(numWays: Int): List<MutableList<Card>> {
        val splitCards: MutableList<MutableList<Card>> = mutableListOf()
        for (i in 1..numWays) {
            splitCards.add(mutableListOf())
        }

        var counter = 0
        deck.forEach { card ->
            splitCards.get(counter++).add(card)
            counter = if (counter == splitCards.size) 0 else counter
        }
        println("SPLIT DECK $numWays WAYS")
        return splitCards
    }
}
