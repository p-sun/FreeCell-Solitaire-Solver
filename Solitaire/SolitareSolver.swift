//
//  SolitareSolver.swift
//  Solitaire
//
//  Created by Paige Sun on 10/22/24.
//

import Foundation

let PRINT_DEBUG = true

public class Board {
    let columns: [[Card]]
    let freeCells: [Card?]
    public let foundations: [Character: Int]  // top card in the foundation
    
    public init(columns: [[Card]], freeCells: [Card?], foundations: [Character : Int]) {
        self.columns = columns
        self.freeCells = freeCells
        self.foundations = foundations
    }
    
    public var isSolved: Bool {
        freeCells.allSatisfy{ $0 == nil } &&
        columns.allSatisfy { $0.isEmpty }
    }
    
    var firstEmptyFreeCellIndex: Int? {
        freeCells.firstIndex(where: { $0 == nil })
    }
           
    // MARK: Columns

    func appendToColumn(_ card: Card, at index: Int) -> Board {
        var newCols = columns
        newCols[index].append(card)
        return Board(columns: newCols, freeCells: freeCells, foundations: foundations)
    }

    func removeLastFromColumn(_ from: Int) -> Board {
        var newCols = columns
        newCols[from].removeLast(1)
        return Board(columns: newCols, freeCells: freeCells, foundations: foundations)
    }
    
    /// Move k cards from one column to another. O(1)
    /// Asserts that from column is not empty, and k is a valid number of cards to move.
    func moveStack(from: Int, to: Int, k: Int) -> Board? {
        guard k <= maxMovableStack(to: to) else {
            return nil
        }
        let fromCol = columns[from]
        assert(fromCol.count > 0)

        func _moveStack() -> Board {
            var newCols = columns
            newCols[from].removeLast(k)
            newCols[to] += fromCol[fromCol.count-k..<fromCol.count]
            return Board(columns: newCols, freeCells: freeCells, foundations: foundations)
        }
        
        let toCol = columns[to]
        if let toCard = toCol.last {
            let fromCard = fromCol[fromCol.count - k]
            return fromCard.canBeStackedOn(toCard) ? _moveStack() : nil
        } else {
            return _moveStack()
        }
    }
    
//    func mergeColumns(from: Int, to: Int) -> Board? {
//        func _moveStack(k :Int) -> Board {
//            var newCols = columns
//            let cardsToMove = newCols[from].dropLast(k)
//            newCols[to] += cardsToMove
//            return Board(columns: newCols, freeCells: freeCells, foundations: foundations)
//        }
//
//        let fromCol = columns[from]
//        guard fromCol.count > 0 else {
//            return nil
//        }
//
//        let toCol = columns[to]
//        if toCol.isEmpty {
//            let k = stackSize(from: from)
//            return k <= maxMovableStack(to: to) ? _moveStack(k: k) : nil
//        } else {
//            guard fromCol.last!.isInSameSequence(toCol.last!) else {
//                return nil
//            }
//            var i = fromCol.count - 1
//            while i - 1 >= 0 && fromCol[i].canBeStackedOn(fromCol[i - 1]) {
//                let cardToMove = fromCol[i-1]
//                i -= 1
//            }
//
//        }
//
//        // TODO
//    }
    
    // MARK: Stack on column

    /// 0 if column is empty
    func stackSize(from: Int) -> Int {
        return _stackSizeForColumn[from]
    }
    
    private lazy var _stackSizeForColumn: [Int] = {
        var sizes = [Int]()
        for col in columns {
            if col.count == 0 {
                sizes.append(0)
            } else {
                var i = col.count - 1
                while i - 1 >= 0 && col[i].canBeStackedOn(col[i - 1]) {
                    i -= 1
                }
                sizes.append(col.count - i)
            }
        }
        return sizes
    }()
    
    func maxMovableStack(to columnIdx: Int) -> Int {
        return _maxMovableStacks[columnIdx]
    }
    
    lazy var maxMovableStackToNonEmptyColumn: Int = {
        return freeCells.filter { $0 == nil }.count + columns.filter { $0.isEmpty }.count
    }()
    
    private lazy var _maxMovableStacks: [Int] = {
        let emptySpaces = maxMovableStackToNonEmptyColumn
        return columns.map { $0.isEmpty ? emptySpaces - 1 : emptySpaces }
    }()
    
    // MARK: Free Cell

    func setFreeCell(_ card: Card, at index: Int) -> Board {
        var newFreeCells = freeCells
        newFreeCells[index] = card
        return Board(columns: columns, freeCells: newFreeCells, foundations: foundations)
    }
    
    func clearFreeCell(_ index: Int) -> Board {
        var newFreeCells = freeCells
        newFreeCells[index] = nil
        return Board(columns: columns, freeCells: newFreeCells, foundations: foundations)
    }

    // MARK: Foundation
    
    private lazy var _minimumFoundationValue: Int = {
        foundations.values.reduce(foundations["h"]!) { minVal, val in
            min(minVal, val)
        }
    }()
    
    func shouldAutomoveToFoundation(_ card: Card) -> Bool {
        return (card.value == 2 || card.value == (_minimumFoundationValue + 1)) && canAddToFoundation(card)
    }
    
    func canAddToFoundation(_ card: Card) -> Bool {
        return foundations[card.suit.rawValue]! == card.value - 1
    }

    func addToFoundation(_ card: Card) -> Board {
        var newFoundations = foundations
        newFoundations[card.suit.rawValue]! += 1
        return Board(columns: columns, freeCells: freeCells, foundations: newFoundations)
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        let foundationsStr = foundations.keys.sorted().map { suitRawValue in
            "\(foundations[suitRawValue]!)\(Card.Suit(rawValue: suitRawValue)!)"
        }.joined(separator: " ")
        let columnsStr = columns.enumerated().map { c, cards in
            let cardsStr = cards.isEmpty ? "-" : cards.map { $0.description }.joined(separator: " ")
            return "<\(c)> \(cardsStr)"
        }.joined(separator: "\n")
        return """
Free Cells: \(freeCells.map {"\($0?.description ?? "-")"}.joined(separator: " "))
Foundations: \(foundationsStr)
Columns:
\(columnsStr)
"""
    }
}

extension Board {
    /**
     Hash boards that are logically the same so we don't explore it again.
     Cards that treated the same:
        - Two cards of same color and same value, one is on a column, one is on a free cell.
     Boards that are treated the same:
        - Same columns in a different order.
        - Same free cells in a different order
     Optimization: Might be easier to track foundations instead.
     */
    public var hashedIdentifier: String {
        let columnsStr = columns
            .map { cards in
                cards
                    .map { card in card.description }
                    .joined(separator: " ")
            }.sorted().joined(separator: "\n")
        let freeCellsStr = freeCells
            .map { $0?.description ?? "-" }
            .sorted().joined(separator: " ")
        return removeColorDuplicates("Free Cells: \(freeCellsStr)\nColumns:\n\(columnsStr)")
    }
    
    // A red card on top of a stack is treated the same as
    // a red card of the same value but with a different suit on a free cell.
    private func removeColorDuplicates(_ text: String) -> String {
        let cardsOnTop = Set(columns.compactMap { $0.last })
        let replacementStrings: [(String, String)] = freeCells.compactMap { card in
            guard let card = card, cardsOnTop.contains(Card(card.value, card.suit.oppositeSuit)) else { return nil }
            let val = card.value
            switch card.suit {
            case .heart, .diamond:
                return ("\(val)\(Card.Suit.diamond)", "\(val)\(Card.Suit.heart)")
            case .spade, .club:
                return ("\(val)\(Card.Suit.club)", "\(val)\(Card.Suit.spade)")
            }
        }
        return replacementStrings.reduce(text) { (partialResult, replace) in
            text.replacingOccurrences(of: replace.0, with: replace.1)
        }
    }
}

public func formattedSolution(_ board: Board, _ solvedBoard: Board, _ moves: [String]) -> String {
    let movesStr = moves
        .enumerated().map {i, move in "\(i)) \(move)"}
        .joined(separator: "\n>>> ")
    return """
\n\n\n+++++++ Solution has \(moves.count) moves +++++++
--- Original Board ---
\(board)

--- Final Board ---
\(solvedBoard)

--- Moves ---
>>> \(movesStr)
+++++++ \(moves.count) moves +++++++
"""
}

public class SolitareSolver {
    private var visitedBoards = Set<String>()

    public init(visitedBoards: Set<String> = Set<String>()) {
        self.visitedBoards = visitedBoards
    }
    
    open func solveBoard(_ board: Board, updatedColumns: [Int] = []) -> (Board, moves: [String])? {
        if PRINT_DEBUG { print("=========\nStart | \(board)") }
        visitedBoards = Set<String>()
        
        let solved = solve(
            board, [],
            updatedColumns: updatedColumns.isEmpty ? Array(board.columns.indices) : updatedColumns, mustUseColumns: [])
        if PRINT_DEBUG, let solved = solved {
            print(formattedSolution(board, solved.0, solved.1))
        }
        return solved
    }

    /// - Parameters:
    ///     - updatedColumns: The columns that have been updated since the last time we moved a card to a free cell.
    ///     - mustUseColumns: Columns where we revealed a new card by moving a card to a free cell or an empty column, and have not used that new card yet.
    open func solve(_ board: Board, _ moves: [String], updatedColumns: [Int], mustUseColumns: [Int]) -> (Board, moves: [String])? {
        if let lastMove = moves.last {
            if PRINT_DEBUG { print("====== Move \(moves.count - 1) ======\n> \(lastMove)\nUpdatedCols: \(updatedColumns)\nMustUseCols: \(mustUseColumns)\n\(board)\n") }
        }
        
//        if PRINT_DEBUG && moves.count >= 200 {
//            print("+_+_+_+_+_+_ Too many moves\n\(board) \n\(moves.enumerated().map { i, move in "\(i) | \(move)" }.joined(separator: "\n"))")
//            return nil
//        }

        // MARK: Greedy Solve
        // Free cell -> Automove to Foundation
        let (board, moves, updatedColumns, mustUseColumns) = applyAutomovesToFoundation(board, moves, updatedColumns: updatedColumns, mustUseColumns: mustUseColumns)
        
        if board.isSolved {
            return (board, moves)
        }
        
        // Prevent cycles, such as moving a card from foundation to a free cell, and back.
        let hashableBoard = board.hashedIdentifier
        guard !visitedBoards.contains(hashableBoard) else {
            if PRINT_DEBUG {
                print(">>> Undo - Already encountered board configuration.")
            }
            return nil
        }
        visitedBoards.insert(hashableBoard)

        // MARK: Backtracking Solve
        
        // FreeCell -> Foundation
        for (i, freeCell) in board.freeCells.enumerated() {
            if let card = freeCell {
                if board.canAddToFoundation(card) {
                    let nextBoard = board.clearFreeCell(i).addToFoundation(card)
                    let nextMoves = moves + ["Move FreeCell \(card) => Foundation"]
                    if let solved = solve(nextBoard, nextMoves, updatedColumns: updatedColumns, mustUseColumns: mustUseColumns) {
                        return solved
                    }
                }
            }
        }

        // Column -> Foundation
        for from in updatedColumns {
            if let card = board.columns[from].last {
                if board.canAddToFoundation(card) {
                    let nextBoard = board.removeLastFromColumn(from).addToFoundation(card)
                    let nextMoves = moves + ["Move Column\(from) \(card) => Foundation"]
                    if let solved = solve(
                        nextBoard, nextMoves, updatedColumns: updatedColumns,
                        mustUseColumns: mustUseColumns.filter { $0 != from }) {
                        return solved
                    }
                }
            }
        }

        // FreeCell -> Column
        for i in board.freeCells.indices {
            if let card = board.freeCells[i] {
                for to in updatedColumns {
                    // Avoid moving a card from a Column to FreeCell and back, without using that column.
                    if !(mustUseColumns.contains(to)) {
                        let toCol = board.columns[to]
                        if toCol.isEmpty || card.canBeStackedOn(toCol.last!) {
                            let nextBoard = board.clearFreeCell(i).appendToColumn(card, at: to)
                            let nextMoves = moves + ["Move FreeCell \(card) => Column\(to)"]
                            if let solved = solve(
                                nextBoard, nextMoves, updatedColumns: updatedColumns,
                                mustUseColumns: mustUseColumns.filter { $0 != to }) {
                                return solved
                            }
                        }
                    }
                }
            }
        }
        
        // Column -> Non-Empty Column
        assert(mustUseColumns.count <= 2)
        if mustUseColumns.count == 2 {
            // If there are 2 mustUseColumns, they must both be involved in a column-to-column move
            for from in mustUseColumns {
                if board.columns[from].count > 0 {
                    let maxStackSize = board.stackSize(from: from)
                    for to in mustUseColumns {
                        if board.columns[to].count > 0 { // To Non-Empty Column
                            if let solved = moveStackAndSolve(board, moves, from: from, to: to, k: maxStackSize, updatedColumns: updatedColumns, mustUseColumns: mustUseColumns) {
                                return solved
                            }
                        }
                    }
                }
            }
        } else {
            // If there is 0 or 1 mustUseColumns, that column must involved in a column-to-column move
            for from in board.columns.indices {
                if board.columns[from].count > 0 {
                    let maxStackSize = board.stackSize(from: from) // TODO: May need to move smaller stack sizes
                    for to in board.columns.indices {
                        if board.columns[to].count > 0 {
                            if let solved = moveStackAndSolve(board, moves, from: from, to: to, k: maxStackSize, updatedColumns: updatedColumns, mustUseColumns: mustUseColumns) {
                                return solved
                            }
                        }
                    }
                }
            }
        }
           
        if mustUseColumns.count == 2 {
            if PRINT_DEBUG { print(">>> Undo. Revealed columns \(mustUseColumns) but didn't use them.") }
            return nil
        }
        
        // Column -> Empty Column
        for from in updatedColumns {
            let maxStackSize = board.stackSize(from: from)
            for to in board.columns.indices.filter({ board.columns[$0].isEmpty }) {
                if let solved = moveStackAndSolve(
                    board, moves, from: from, to: to, k: maxStackSize, updatedColumns: updatedColumns, mustUseColumns: mustUseColumns) {
                    return solved
                }
            }
        }

        // Column -> FreeCell
        if let emptyFreeCellIdx = board.firstEmptyFreeCellIndex {
            for from in board.columns.indices {
                if let card = board.columns[from].last {
                    let stackSize = board.stackSize(from: from)
                    if stackSize == 1 ||
                        // Only split up a stack if the stack is bigger than the allowed movable stack size.
                        stackSize > board.maxMovableStackToNonEmptyColumn {
                        let nextBoard = board.removeLastFromColumn(from).setFreeCell(card, at: emptyFreeCellIdx)
                        let nextMoves = moves + ["Move Column\(from) \(card) => FreeCell"]
//                        let updatedCols = updatedColumns.contains(from) ? updatedColumns : updatedColumns + [from]
                        var mustUseCols = mustUseColumns
                        if !mustUseCols.contains(from) {
                            mustUseCols.append(from)
                        }
                        if let solved = solve(nextBoard, nextMoves, updatedColumns: mustUseCols,
                                              mustUseColumns: mustUseCols) {
                            return solved
                        }
                    }
                }
            }
        }
        
        if PRINT_DEBUG { print(">>> Undo - No more moves.") }
        return nil
    }
    
    // MARK: Automove to Foundation
    
    public func applyAutomovesToFoundation(_ board: Board, _ moves: [String], updatedColumns: [Int], mustUseColumns: [Int]) -> (board: Board, moves: [String], updatedColumns: [Int], mustUseColumns: [Int]) {
        var board = board
        var moves = moves
        var updatedColumns = updatedColumns
        var mustUseColumns = mustUseColumns
        while let (newBoard, newMove, updatedColumn) = automoveToFoundation(board) {
            board = newBoard
            if let updatedColumn = updatedColumn {
                if !updatedColumns.contains(updatedColumn) {
                    updatedColumns.append(updatedColumn)
                }
                mustUseColumns.removeAll(where: { $0 == updatedColumn })
            }
            moves.append(newMove)
            if PRINT_DEBUG {
                print("> " + newMove)
            }
        }
        return (board, moves, updatedColumns, mustUseColumns)
    }
    
    private func automoveToFoundation(_ board: Board) -> (Board, move: String, updatedColumn: Int?)? {
        for (i, freeCell) in board.freeCells.enumerated() {
            if let card = freeCell {
                if board.shouldAutomoveToFoundation(card) {
                    let newBoard = board.clearFreeCell(i).addToFoundation(card)
                    return (newBoard, "Automove FreeCell \(card) => Foundation", updatedColumn: nil)
                }
            }
        }
        
        for (from, fromCol) in board.columns.enumerated() {
            if let card = fromCol.last {
                if board.shouldAutomoveToFoundation(card) {
                    let newBoard = board.removeLastFromColumn(from).addToFoundation(card)
                    return (newBoard, "Automove Column\(from) \(card) => Foundation", updatedColumn: from)
                }
            }
        }
        
        return nil
    }
    
    // MARK: Column -> Column
    private func moveStackAndSolve(_ board: Board, _ moves: [String], from: Int, to: Int, k: Int, updatedColumns: [Int], mustUseColumns: [Int]) -> (Board, moves: [String])? {
        guard updatedColumns.contains(from) || updatedColumns.contains(to) else {
            return nil
        }
        let toEmptyCol = board.columns[to].isEmpty
        let moveFullStackToEmptyColumn = (k == board.columns[from].count) && toEmptyCol
        if from != to && !moveFullStackToEmptyColumn {
            if let newBoard = board.moveStack(from: from, to: to, k: k) {
                let fromCol = board.columns[from]
                let fromCard = fromCol[fromCol.count-k]
                let toCard = board.columns[to].last?.description ?? "Empty"
                let nextMoves = moves + ["Move Column\(from) \(fromCard) onto Column\(to) \(toCard) : \(k) cards"]
                
                var updatedColumns = updatedColumns
                if !updatedColumns.contains(from) {
                    updatedColumns.insert(from, at: 0)
                }
                if !updatedColumns.contains(to) {
                    updatedColumns.insert(to, at: 0)
                }
                var mustUseColumns = mustUseColumns.filter { $0 != to }
                if toEmptyCol && !mustUseColumns.contains(from) {
                    mustUseColumns.insert(from, at: 0)
                }
                if let solved = solve(newBoard, nextMoves, updatedColumns: updatedColumns,
                                      mustUseColumns: mustUseColumns) {
                    return solved
                }
            }
        }
        return nil
    }
}
