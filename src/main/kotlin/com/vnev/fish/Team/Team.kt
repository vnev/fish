package com.vnev.fish.Team

import com.vnev.fish.Player.Player

enum class TeamNumber {
    ONE, TWO
}

class Team {
    val MAX_PLAYERS = 3
    lateinit var players: MutableList<Player>

    constructor(teamNumber: TeamNumber, players: MutableList<Player>) {
        this.players = players
    }

}