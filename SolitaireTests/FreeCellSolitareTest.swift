import XCTest
import Solitaire

final class FreeCellSolitareTest: XCTestCase {

    func testAutomoveToFoundation() {
        let board = BoardBuilder.build(
            columns: "",
            freeCells: [nil, Card(1, .heart), Card(1, .club), Card(2, .club)])
        
        let nextStep = SolitareSolver().applyAutomovesToFoundation(Step(board, moves: [], updatedColumns: [], mustUseColumns: [2,3]))
        XCTAssertTrue(nextStep.board.isSolved)
        XCTAssertEqual(nextStep.board.foundations[Card.Suit.heart.rawValue], 1)
        XCTAssertEqual(nextStep.board.foundations[Card.Suit.club.rawValue], 2)
        XCTAssertEqual(nextStep.mustUseColumns, [2,3])
    }
    
    func testSolveMoving_fromFreeCells_toFoundation() {
        let board = BoardBuilder.build(
            columns: "",
            freeCells: [nil, Card(1, .heart), Card(1, .club), Card(2, .club)])
        if let (solvedBoard, _) = SolitareSolver().solveBoard(board) {
            XCTAssertTrue(solvedBoard.isSolved)
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 1)
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.club.rawValue], 2)
        } else {
            XCTFail()
        }
    }
    
    func testSolveMoving_fromColumns_toFoundation() {
        let board = BoardBuilder.build(
            columns:
"""
2c
3c 1c 1h
""",
            freeCells: [nil, nil, nil, nil])
        if let (solvedBoard, _) = SolitareSolver().solveBoard(board) {
            XCTAssertTrue(solvedBoard.isSolved)
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 1)
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.club.rawValue], 3)
        } else {
            XCTFail()
        }
    }
    
    func testSolveMoving_fromColumns_toColumns() {
        let board = BoardBuilder.build(
            columns:
"""
9c
10h 6h 5s 4h
7c
""",
            freeCells: [nil, nil, nil, nil])
        if let (_, _) = SolitareSolver().solveBoard(board) {
            XCTFail()
        } else {
_ = """
Free Cells: nil nil nil nil
Foundations: ["d": 0, "c": 0, "s": 0, "h": 0]
[[], [10♡, 9♣], [7♣, 6♡, 5♠, 4♡]]
"""
        }
    }
    
    func testSolveMoving_fromColumns_toColumns_toFoundation() {
        let board = BoardBuilder.build(
            columns:
"""
2h
3s 3h 2s 1h
1s
""",
            freeCells: [nil, nil, nil, nil])
        XCTAssertEqual(board.description, """
Free Cells: - - - -
Foundations: 0♣ 0♢ 0♡ 0♠
Columns:
<0> 2♡
<1> 3♠ 3♡ 2♠ 1♡
<2> 1♠
""")
        if let (solvedBoard, _) = SolitareSolver().solveBoard(board) {
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 3)
            XCTAssertEqual(solvedBoard.foundations[Card.Suit.spade.rawValue], 3)
            let expected = """
Free Cells: - - - -
Foundations: 0♣ 0♢ 3♡ 3♠
Columns:
<0> -
<1> -
<2> -
"""
            XCTAssertEqual(solvedBoard.description, expected)
        } else {
            XCTFail()
        }
    }
    
    func testSolveMoving_fromColumns_toColumns_shouldNotChangeWhenMissingFoundation() {
        let board = BoardBuilder.build(
            columns:
"""
6c
6s 5h 4c
""",
            freeCells: [nil, nil, nil, nil])
        if let (_, _) = SolitareSolver().solveBoard(board) {
            XCTFail()
        }
    }
    
    func testSmallDeck1_Fast() {
        solve_smallDeck_1(useFastSolve: true)
    }
    
    func testSmallDeck1_Slow() {
        solve_smallDeck_1(useFastSolve: false)
    }
    
    func testSmallDeck2_Fast() {
        solve_smallDeck_2(useFastSolve: true)
    }
    
    func testSmallDeck2_Slow() {
        solve_smallDeck_2(useFastSolve: false)
    }

    func testFullDeck1_Fast() {
        solve_fullDeck_1(useFastSolve: true)
    }
    
    func testFullDeck1_Slow() {
        solve_fullDeck_1(useFastSolve: false)
    }

    func testFullDeck2_Fast() {
        solve_fullDeck_2(useFastSolve: true)
    }

    func testFullDeck2_Slow() {
        solve_fullDeck_2(useFastSolve: false)
    }
    
    func testFullDeck3_Fast() {
        solve_fullDeck_3(useFastSolve: true)
    }

    func testFullDeck3_Slow() {
        solve_fullDeck_3(useFastSolve: false)
    }
    
    func testBoardHashId() {
        let board = BoardBuilder.build(
            columns:
"""
5h
6s
7c
4s 8d
""",
            freeCells: [Card(5, .diamond), Card(6, .club), Card(4, .heart), nil])
        let expected = """
Free Cells: - 4♡ 5♢ 6♠
Columns:
4♠ 8♢
5♡
6♠
7♣
"""
        XCTAssertEqual(board.hashedIdentifier, expected)
    }
}

// MARK: - Solve Decks
func solve_smallDeck_1(useFastSolve: Bool) {
    let board = BoardBuilder.build(
        columns:
"""
13♡ 12♣ 4♢ 11♢ 10♠ 9♢ 8♠ 7♢ 6♠
11♠ 6♡ 6♢ 5♢ 5♣ 13♠ 12♡ 11♣ 10♢ 9♣ 8♢ 2♠ 2♣ 7♠
4♠ 3♢
10♡ 9♠ 8♡
5♠ 4♡ 3♣ 2♡
13♢ 12♠ 11♡ 10♣ 9♡ 8♣
13♣
1♡ 7♣ 12♢ 7♡ 6♣ 5♡ 4♣ 3♡
"""
            .replacingOccurrences(of: "♡", with: "h")
            .replacingOccurrences(of: "♠", with: "s")
            .replacingOccurrences(of: "♢", with: "d")
            .replacingOccurrences(of: "♣", with: "c"),
        freeCells: [Card(3, .spade), nil, nil, nil],
        foundations: ["c":1, "d":2, "h":0, "s":1],
        isFullDeck: true)
    if let (solvedBoard, _) = SolitareSolver().solveBoard(board, updatedColumns: [0, 6], useFastSolve: useFastSolve) {
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.spade.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.diamond.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.club.rawValue], 13)
        XCTAssertTrue(solvedBoard.isSolved)
        let expected = """
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
"""
        XCTAssertEqual(solvedBoard.description, expected)
    } else {
        XCTFail()
    }
}

func solve_smallDeck_2(useFastSolve: Bool) {
    let board = BoardBuilder.build(
        columns:
"""
5h 7s 6h
13h 12c 11h
6s
12s 8h
9h 8s 7h
13s 12h 11c 10h
13c
9s
""",
        freeCells: [Card(10, .spade), Card(11,.spade), nil, nil],
        foundations: ["c":10, "d":13, "h":4, "s":5])
    if let (solvedBoard, _) = SolitareSolver().solveBoard(board, updatedColumns: [3], useFastSolve: useFastSolve) {
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.spade.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.diamond.rawValue], 13)
        XCTAssertEqual(solvedBoard.foundations[Card.Suit.club.rawValue], 13)
        XCTAssertTrue(solvedBoard.isSolved)
        let expected = """
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
"""
        XCTAssertEqual(solvedBoard.description, expected)
    } else {
        XCTFail()
    }
}

func solve_fullDeck_1(useFastSolve: Bool) {
    let board = BoardBuilder.build(
        columns:
"""
5h 7s 3d ks 6s kh 10d
3h 8c qs 8s kc kd 6c
7h 9d 10s 3c 9c 2d 7c
9s 4d jc 7d js 6d qc
jh 4h 6h 5c 4c 5d
2c qd ah 8d 4s jd
ad 5s 10c qh 9h 3s
8h 2s 10h as ac 2h
""",
        freeCells: [nil, nil, nil, nil],
        isFullDeck: true)
    if let (solvedBoard, _) = SolitareSolver().solveBoard(board, useFastSolve: useFastSolve) {
        assertBoardIsSolved(solvedBoard)
    } else {
        XCTFail()
    }
}

func solve_fullDeck_2(useFastSolve: Bool) {
    let board = BoardBuilder.build(
        columns:
"""
10c qs 9c 2h 9h 8c 3c
7c 4c 7s 2c 2s ad as
5h 3h 3s 8h 9d js kd
ah 7d 6d 4h jh 8s 5s
jc 5c 6s qd kh 10h
9s 5d 6c jd qc 6h
4s ac qh ks 3d kc
10d 7h 2d 4d 8d 10s
""",
        freeCells: [nil, nil, nil, nil],
        isFullDeck: true)
    if let (solvedBoard, _) = SolitareSolver().solveBoard(board, useFastSolve: useFastSolve) {
        assertBoardIsSolved(solvedBoard)
    } else {
        XCTFail()
    }
}

func solve_fullDeck_3(useFastSolve: Bool) {
    let board = BoardBuilder.build(
        columns:
"""
qh 8d 7s 4c 6d 2c 2d
7d 6s qs 8c js ks 3s
5d 10h 3h 5s 3d 3c 7c
8s kd qc 8h 5h as ah
kc 9h jd 9s 6c ad
7h 9c 4h 2s 10c 4s
jh 6h 2h 5c qd 10s
4d 9d jc ac kh 10d
""",
        freeCells: [nil, nil, nil, nil],
        isFullDeck: true)
    if let (solvedBoard, _) = SolitareSolver().solveBoard(board, useFastSolve: useFastSolve) {
        assertBoardIsSolved(solvedBoard)
    } else {
        XCTFail()
    }
}

// MARK: - Utils

func assertBoardIsSolved(_ solvedBoard: Board) {
    XCTAssertEqual(solvedBoard.foundations[Card.Suit.heart.rawValue], 13)
    XCTAssertEqual(solvedBoard.foundations[Card.Suit.spade.rawValue], 13)
    XCTAssertEqual(solvedBoard.foundations[Card.Suit.diamond.rawValue], 13)
    XCTAssertEqual(solvedBoard.foundations[Card.Suit.club.rawValue], 13)
    let expected = """
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
"""
    XCTAssertEqual(solvedBoard.description, expected)
}
