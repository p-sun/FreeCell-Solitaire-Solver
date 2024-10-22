//
//  SolitareSolver.swift
//  Solitaire
//
//  Created by Paige Sun on 10/22/24.
//

import Foundation

let PRINT_DEBUG = true

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
                            let nextMoves = moves + ["Move FreeCell \(card) => <\(to)>"]
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
                    return (newBoard, "Automove \(card) : FreeCell => Foundation", updatedColumn: nil)
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
                let toCard = board.columns[to].last?.description ?? "empty"
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
