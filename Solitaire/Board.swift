//
//  Board.swift
//  Solitaire
//
//  Created by Paige Sun on 10/22/24.
//

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
