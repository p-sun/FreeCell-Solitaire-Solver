# FreeCell-Solitaire-Solver
A FreeCell Solitaire solver written in Swift. 

I was playing FreeCell Solitare on [YouTube Playables](https://www.youtube.com/playables/Ugkxbnpb-Zfu90iTv-d_1rZA5kUiiZwUz5U3), and thought, "I wonder if I can write an algorithm to solve this?". The answer was yes! I've used these instructions to solve a deck. Like the game of solitare, this was a fun excercise in recursion and logic deduction. 

Most of the solver logic are in `BoardBuilder` and `Board` classes.

Potential next steps:
- Rewrite the search with BFS to find a solve with the fewest number of moves.
- For the BFS solve Prioritize solving boards with more cards in-order and already moved to the foundation.
- Refactor BoardBuilder and Board with shorter functions.
- Build a the UI for a Solitaire game.
- Test more decks.
- Write a test to generate small games with valid moves, to find games this solver can't solve. Compare my solver's solution with generated moves to find more logical shortcuts that we can use to prioritize certain moves, or skip exploring certain moves earlier.

See `FreeCellSolitareTest` for tests on specific deck combinations. The solver prints text to indicate the solution.

```
+++++++ Solution has 121 moves +++++++
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
>>> 0) Move Column4 5♢ onto Column1 6♣ : 1 cards
>>> 1) Move Column4 4♣ onto Column1 5♢ : 1 cards
>>> 2) Move Column4 6♡ onto Column2 7♣ : 2 cards
>>> 3) Move Column4 4♡ onto Column2 5♣ : 1 cards
>>> 4) Move Column4 11♡ onto Column3 12♣ : 1 cards
>>> 5) Move Column6 3♠ onto Column2 4♡ : 1 cards
>>> 6) Move Column7 2♡ onto Column2 3♠ : 1 cards
>>> 7) Automove Column7 1♣ => Foundation
>>> 8) Automove Column7 1♠ => Foundation
>>> 9) Move Column0 10♢ onto Column4 empty : 1 cards
>>> 10) Move Column3 12♣ onto Column0 13♡ : 2 cards
>>> 11) Move Column3 6♢ => FreeCell
>>> 12) Move Column4 10♢ onto Column3 11♠ : 1 cards
>>> 13) Move FreeCell 6♢ => <4>
>>> 14) Move Column6 9♡ => FreeCell
>>> 15) Move Column6 12♡ => FreeCell
>>> 16) Move Column6 10♣ onto Column0 11♡ : 1 cards
>>> 17) Move FreeCell 9♡ => <0>
>>> 18) Move Column6 5♠ onto Column4 6♢ : 1 cards
>>> 19) Automove Column6 1♢ => Foundation
>>> 20) Move FreeCell 12♡ => <6>
>>> 21) Move Column3 11♠ onto Column6 12♡ : 2 cards
>>> 22) Move Column3 7♢ => FreeCell
>>> 23) Move Column3 11♣ => FreeCell
>>> 24) Move Column3 4♢ onto Column4 5♠ : 1 cards
>>> 25) Move Column3 9♠ onto Column6 10♢ : 1 cards
>>> 26) Move Column7 10♡ => FreeCell
>>> 27) Automove Column7 2♠ => Foundation
>>> 28) Move Column7 8♡ onto Column6 9♠ : 1 cards
>>> 29) Move FreeCell 11♣ => <7>
>>> 30) Move FreeCell 10♡ => <7>
>>> 31) Move Column2 2♡ => FreeCell
>>> 32) Move Column2 3♠ => Foundation
>>> 33) Move Column5 11♢ => FreeCell
>>> 34) Move Column5 4♠ => Foundation
>>> 35) Move Column5 8♢ onto Column3 empty : 1 cards
>>> 36) Automove Column5 1♡ => Foundation
>>> 37) Automove 2♡ : FreeCell => Foundation
>>> 38) Move Column7 11♣ onto Column5 12♢ : 2 cards
>>> 39) Move FreeCell 7♢ => <7>
>>> 40) Move Column1 6♣ onto Column7 7♢ : 3 cards
>>> 41) Move Column2 4♡ => FreeCell
>>> 42) Move Column2 5♣ => FreeCell
>>> 43) Move Column4 4♢ => FreeCell
>>> 44) Move Column4 5♠ => Foundation
>>> 45) Move FreeCell 5♣ => <4>
>>> 46) Move FreeCell 4♡ => <4>
>>> 47) Move Column2 7♣ onto Column6 8♡ : 2 cards
>>> 48) Automove Column2 2♢ => Foundation
>>> 49) Move Column2 9♣ onto Column5 10♡ : 1 cards
>>> 50) Move Column2 3♣ onto Column4 4♡ : 1 cards
>>> 51) Move Column3 8♢ onto Column5 9♣ : 1 cards
>>> 52) Move FreeCell 11♢ => <3>
>>> 53) Move Column1 13♢ => FreeCell
>>> 54) Move Column1 13♣ => FreeCell
>>> 55) Move Column1 8♠ onto Column0 9♡ : 1 cards
>>> 56) Move Column3 11♢ onto Column1 12♠ : 1 cards
>>> 57) Move FreeCell 13♢ => <3>
>>> 58) Move Column1 12♠ onto Column3 13♢ : 2 cards
>>> 59) Move Column2 10♠ onto Column3 11♢ : 1 cards
>>> 60) Move Column1 8♣ onto Column2 9♢ : 1 cards
>>> 61) Move Column1 3♡ => Foundation
>>> 62) Move FreeCell 13♣ => <1>
>>> 63) Move Column2 9♢ onto Column3 10♠ : 2 cards
>>> 64) Move Column2 7♡ onto Column0 8♠ : 1 cards
>>> 65) Move FreeCell 4♢ => <2>
>>> 66) Move Column7 7♢ onto Column3 8♣ : 4 cards
>>> 67) Move Column0 7♡ => FreeCell
>>> 68) Move Column0 8♠ => FreeCell
>>> 69) Move Column0 9♡ => FreeCell
>>> 70) Move Column4 3♣ => FreeCell
>>> 71) Move Column4 4♡ => Foundation
>>> 72) Move Column2 4♢ onto Column4 5♣ : 1 cards
>>> 73) Move FreeCell 9♡ => <2>
>>> 74) Move FreeCell 8♠ => <2>
>>> 75) Move FreeCell 7♡ => <2>
>>> 76) Move FreeCell 3♣ => <4>
>>> 77) Move Column0 13♡ onto Column7 empty : 4 cards
>>> 78) Move Column0 6♠ => Foundation
>>> 79) Move Column2 9♡ onto Column7 10♣ : 3 cards
>>> 80) Move Column0 13♠ onto Column2 empty : 1 cards
>>> 81) Move Column0 3♢ => Foundation
>>> 82) Move Column0 7♠ => Foundation
>>> 83) Move Column0 5♡ => Foundation
>>> 84) Move Column5 12♢ onto Column2 13♠ : 5 cards
>>> 85) Automove Column5 2♣ => Foundation
>>> 86) Automove Column4 3♣ => Foundation
>>> 87) Automove Column3 4♣ => Foundation
>>> 88) Automove Column4 4♢ => Foundation
>>> 89) Automove Column3 5♢ => Foundation
>>> 90) Automove Column4 5♣ => Foundation
>>> 91) Automove Column3 6♣ => Foundation
>>> 92) Automove Column4 6♢ => Foundation
>>> 93) Automove Column6 6♡ => Foundation
>>> 94) Automove Column3 7♢ => Foundation
>>> 95) Automove Column6 7♣ => Foundation
>>> 96) Automove Column7 7♡ => Foundation
>>> 97) Automove Column2 8♢ => Foundation
>>> 98) Automove Column3 8♣ => Foundation
>>> 99) Automove Column6 8♡ => Foundation
>>> 100) Automove Column7 8♠ => Foundation
>>> 101) Automove Column2 9♣ => Foundation
>>> 102) Automove Column3 9♢ => Foundation
>>> 103) Automove Column6 9♠ => Foundation
>>> 104) Automove Column7 9♡ => Foundation
>>> 105) Automove Column2 10♡ => Foundation
>>> 106) Automove Column3 10♠ => Foundation
>>> 107) Automove Column6 10♢ => Foundation
>>> 108) Automove Column7 10♣ => Foundation
>>> 109) Automove Column2 11♣ => Foundation
>>> 110) Automove Column3 11♢ => Foundation
>>> 111) Automove Column6 11♠ => Foundation
>>> 112) Automove Column7 11♡ => Foundation
>>> 113) Automove Column2 12♢ => Foundation
>>> 114) Automove Column3 12♠ => Foundation
>>> 115) Automove Column6 12♡ => Foundation
>>> 116) Automove Column7 12♣ => Foundation
>>> 117) Automove Column1 13♣ => Foundation
>>> 118) Automove Column2 13♠ => Foundation
>>> 119) Automove Column3 13♢ => Foundation
>>> 120) Automove Column7 13♡ => Foundation
+++++++ 121 moves +++++++
```
