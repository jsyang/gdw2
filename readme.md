# Gamedev weekend 2

Original development finished on 30/05/2013. Current version has been patched to
run in modern browsers (WebAudio API was changed since 2013).

## Game
This is a web version of a popular board game: [Kulami](https://boardgamegeek.com/boardgame/108831/kulami)

Features:
- an intermediate skill-level AI player with taunts (filthy meatbag!)
- RANDOM or a completely user-defined board layout
- final score breakdown

## How to play

#### Construct board layout
Drag the tiles to form a board of non-overlapping tiles. Overlapped tiles are shown in red. 
Double click a tile to change its rotation. Or click on the RANDOM button to generate a random
valid game layout.

#### Game rules

This game is won by scoring. The player who owns the most cells wins.
On each turn, a player places a marble on an empty spot on a tile.

A player owns a tile when his marbles take up a majority of the cells 
on the tile.

A player's score is the sum of the cells in owned tiles.

Players take turns placing one marble per turn in an empty cell on a tile that 
doesn't contain the last move.

A move is legal only if it lies on the same row or column as the last
marble played.

#### End game

The game ends when a player has no legal moves left on their turn.

A tile per tile breakdown of the final score is revealed when the game ends.

