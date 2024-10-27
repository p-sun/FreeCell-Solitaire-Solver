# FreeCell-Solitaire-Solver
A FreeCell Solitaire solver to deterministically find solutions for any deck, using one of two methods.
  * __DFS Solve__: Find a solution for any deck. `useFastSolveSolve = true`. Faster than BFS solve.
  * __BFS Solve__: Finds one of the BEST solutions for any deck. I use weighted heureistics to estimate how good a game state is from the final solution, and use that to filter the queue of possible game states for the BFS traversal. `useFastSolveSolve = false`

I was playing FreeCell Solitare on [YouTube Playables](https://www.youtube.com/playables/Ugkxbnpb-Zfu90iTv-d_1rZA5kUiiZwUz5U3), and thought, "I wonder if I can write an algorithm to solve this?". The answer was yes! Like the game of solitare, this was a fun excercise in recursion and logic deduction. 

Most of the solver logic are in [SolitareSolver.swift](https://github.com/p-sun/FreeCell-Solitaire-Solver/blob/main/Solitaire/SolitareSolver.swift).

## Potential Next Steps
- Refactor Board and SolitareSolver with shorter functions.
- Build UI and game controllers for the Solitaire game.
- Test more decks.
- Write a test to generate small games with valid moves, to find games this solver can't solve. Compare my solver's solution with generated moves to find more logical shortcuts that we can use to prioritize certain moves, or skip exploring certain moves earlier.
- Improve the DFS solving algorithm using path compression. If we could improve the game state (e.g. merge two stacks, move card to foundation) without moving some cards, then then undo just those moves.
- Refactor list of moves (e.g. column-to-column, column-to-foundation) and their text descriptions into an enum to reduce memory usage.

## Test Deck

See [`FreeCellSolitareTest`](https://github.com/p-sun/FreeCell-Solitaire-Solver/blob/ed3a8ed712660ea3cda500e0b44c8f5484c07b5c/SolitaireTests/FreeCellSolitareTest.swift#L263)'s `solve_fullDeck_1()` for the test on this deck. The BFS solver prints the following text, which was tested on a real game on YouTube Playables.

<img src="https://github.com/user-attachments/assets/135308a6-3cea-4d1d-9b35-467b2ff8399a" width="600">

```
+++++++ Solution has 101 moves +++++++
--- Original Board ---
Free Cells: - - - -
Foundations: 0♣ 0♢ 0♡ 0♠
Columns:
<0> 5♡ 7♠ 3♢ 13♠ 6♠ 13♡ 10♢
<1> 3♡ 8♣ 12♠ 8♠ 13♣ 13♢ 6♣
<2> 7♡ 9♢ 10♠ 3♣ 9♣ 2♢ 7♣
<3> 9♠ 4♢ 11♣ 7♢ 11♠ 6♢ 12♣
<4> 11♡ 4♡ 6♡ 5♣ 4♣ 5♢
<5> 2♣ 12♢ 1♡ 8♢ 4♠ 11♢
<6> 1♢ 5♠ 10♣ 12♡ 9♡ 3♠
<7> 8♡ 2♠ 10♡ 1♠ 1♣ 2♡

--- Final Board ---
Free Cells: - - - -
Foundations: 13♣ 13♢ 13♡ 13♠
Columns:
<0> -
<1> -
<2> -
<3> -
<4> -
<5> -
<6> -
<7> -

--- Moves ---
>>> 0) Move Column5 11♢ onto Column3 12♣ : 1 cards
>>> 1) Move Column5 4♠ onto Column4 5♢ : 1 cards
>>> 2) Move Column7 2♡ onto Column6 3♠ : 1 cards
>>> 3) Automove Column7 1♣ => Foundation
>>> 4) Automove Column7 1♠ => Foundation
>>> 5) Move Column7 10♡ => FreeCell
>>> 6) Automove Column7 2♠ => Foundation
>>> 7) Move Column2 7♣ onto Column7 8♡ : 1 cards
>>> 8) Move Column2 2♢ => FreeCell
>>> 9) Move Column5 8♢ onto Column2 9♣ : 1 cards
>>> 10) Automove Column5 1♡ => Foundation
>>> 11) Automove Column6 2♡ => Foundation
>>> 12) Move Column6 3♠ => Foundation
>>> 13) Move Column5 12♢ => FreeCell
>>> 14) Automove Column5 2♣ => Foundation
>>> 15) Move FreeCell 10♡ => Column5
>>> 16) Move Column2 9♣ onto Column5 10♡ : 2 cards
>>> 17) Move FreeCell 2♢ => Column2
>>> 18) Move Column6 9♡ => FreeCell
>>> 19) Move Column6 12♡ => FreeCell
>>> 20) Move Column6 10♣ onto Column3 11♢ : 1 cards
>>> 21) Move Column6 5♠ => FreeCell
>>> 22) Automove Column6 1♢ => Foundation
>>> 23) Automove Column2 2♢ => Foundation
>>> 24) Automove Column2 3♣ => Foundation
>>> 25) Move FreeCell 9♡ => Column6
>>> 26) Move Column6 9♡ onto Column3 10♣ : 1 cards
>>> 27) Move Column2 10♠ onto Column6 Empty : 1 cards
>>> 28) Move Column2 9♢ onto Column6 10♠ : 1 cards
>>> 29) Move Column4 4♠ => FreeCell
>>> 30) Move FreeCell 4♠ => Foundation
>>> 31) Move FreeCell 5♠ => Foundation
>>> 32) Move Column4 5♢ onto Column1 6♣ : 1 cards
>>> 33) Move Column4 4♣ => Foundation
>>> 34) Move Column4 6♡ onto Column7 7♣ : 2 cards
>>> 35) Move Column4 4♡ onto Column7 5♣ : 1 cards
>>> 36) Move Column6 10♠ onto Column4 11♡ : 2 cards
>>> 37) Move Column1 6♣ onto Column2 7♡ : 2 cards
>>> 38) Move Column1 13♢ onto Column6 Empty : 1 cards
>>> 39) Move Column1 13♣ => FreeCell
>>> 40) Move Column1 8♠ onto Column3 9♡ : 1 cards
>>> 41) Move Column1 12♠ onto Column6 13♢ : 1 cards
>>> 42) Move Column1 8♣ onto Column4 9♢ : 1 cards
>>> 43) Automove Column1 3♡ => Foundation
>>> 44) Move FreeCell 13♣ => Column1
>>> 45) Move Column7 4♡ => FreeCell
>>> 46) Move FreeCell 4♡ => Foundation
>>> 47) Move Column7 5♣ => Foundation
>>> 48) Move Column2 5♢ => FreeCell
>>> 49) Move Column2 6♣ => Foundation
>>> 50) Move Column2 7♡ onto Column3 8♠ : 1 cards
>>> 51) Move FreeCell 12♡ => Column2
>>> 52) Move Column2 12♡ onto Column1 13♣ : 1 cards
>>> 53) Move Column0 10♢ => FreeCell
>>> 54) Move Column0 13♡ onto Column2 Empty : 1 cards
>>> 55) Move Column0 6♠ => Foundation
>>> 56) Move Column0 13♠ => FreeCell
>>> 57) Automove Column0 3♢ => Foundation
>>> 58) Move Column0 7♠ => Foundation
>>> 59) Move Column0 5♡ => Foundation
>>> 60) Move FreeCell 13♠ => Column0
>>> 61) Move FreeCell 12♢ => Column0
>>> 62) Move Column3 7♡ => FreeCell
>>> 63) Move Column3 8♠ => Foundation
>>> 64) Move Column7 6♡ => FreeCell
>>> 65) Move FreeCell 6♡ => Foundation
>>> 66) Move FreeCell 7♡ => Foundation
>>> 67) Move Column7 7♣ => Foundation
>>> 68) Move Column7 8♡ => Foundation
>>> 69) Move Column3 9♡ => FreeCell
>>> 70) Move FreeCell 9♡ => Foundation
>>> 71) Move Column3 12♣ onto Column2 13♡ : 3 cards
>>> 72) Move Column3 6♢ onto Column7 Empty : 1 cards
>>> 73) Move Column3 11♠ onto Column0 12♢ : 1 cards
>>> 74) Move Column3 7♢ onto Column4 8♣ : 1 cards
>>> 75) Move Column3 11♣ onto Column1 12♡ : 1 cards
>>> 76) Automove Column3 4♢ => Foundation
>>> 77) Automove FreeCell 5♢ => Foundation
>>> 78) Automove Column7 6♢ => Foundation
>>> 79) Automove Column4 7♢ => Foundation
>>> 80) Automove Column4 8♣ => Foundation
>>> 81) Automove Column5 8♢ => Foundation
>>> 82) Automove Column3 9♠ => Foundation
>>> 83) Automove Column4 9♢ => Foundation
>>> 84) Automove Column5 9♣ => Foundation
>>> 85) Automove FreeCell 10♢ => Foundation
>>> 86) Automove Column2 10♣ => Foundation
>>> 87) Automove Column4 10♠ => Foundation
>>> 88) Automove Column5 10♡ => Foundation
>>> 89) Automove Column0 11♠ => Foundation
>>> 90) Automove Column1 11♣ => Foundation
>>> 91) Automove Column2 11♢ => Foundation
>>> 92) Automove Column4 11♡ => Foundation
>>> 93) Automove Column0 12♢ => Foundation
>>> 94) Automove Column1 12♡ => Foundation
>>> 95) Automove Column2 12♣ => Foundation
>>> 96) Automove Column6 12♠ => Foundation
>>> 97) Automove Column0 13♠ => Foundation
>>> 98) Automove Column1 13♣ => Foundation
>>> 99) Automove Column2 13♡ => Foundation
>>> 100) Automove Column6 13♢ => Foundation
+++++++ 101 moves +++++++
```
