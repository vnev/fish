package com.vnev.fish

import com.vnev.fish.Deck.Deck
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class FishApplication

fun main(args: Array<String>) {
	runApplication<FishApplication>(*args)
	val deck = Deck()
	deck.split(6)
}
