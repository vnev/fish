## Fish
---

### Card
 - image: Love2D Image object
 - suit: Card suit
 - value: Card numeric value
 - id: `<suit>+<value>`
 - subdeck_id: `SubDecks.id`

### Deck
 - cards: set of `Card`s

### SubDecks - 8 total subdecks (2-7 and 9-A for each suit)
 - id: one of `['diamond_high', 'diamond_low', 'spade_high', 'spade_low', 'club_high', 'club_low', 'heart_high', 'heart_low']`
 - won_by: team ID

### PlayerHand
 - cards: starts with 8 random cards drawn from `Deck`
 - handSize: current hand size, starts at 8
 - suits: Set of all suits in player's current `cards`, used for quicker lookup

### Player
 - team: Team ID
 - id: Player ID
 - hand: pointer to `PlayerHand`

### Team
 - players: Set of Player IDs
 - score: team score
 - numHandsWon: number of SubDecks won
