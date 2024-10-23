//
//  BoardBuilder.swift
//  Solitaire
//
//  Created by Paige Sun on 10/22/24.
//

public struct BoardBuilder {
    public static func build(columns columnsRaw: String,
                      freeCells: [Card?] = [nil, nil, nil, nil],
                      foundations: [Character : Int]? = nil,
                      isFullDeck: Bool = false) -> Board {
        var columns = [[Card]]()
        for rawCards in columnsRaw.components(separatedBy: .newlines) {
            columns.append(_buildCards(rawCards))
        }
        
        var emptyFoundation = [Character: Int]()
        for suit in Card.Suit.all {
            emptyFoundation[suit.rawValue] = 0
        }
        
        let board = Board(columns: columns, freeCells: freeCells, foundations: foundations ?? emptyFoundation)
        _validateDeck(board, isFullDeck: isFullDeck)
        return board
    }
    
    private static func _buildCards(_ rawCards: String) -> [Card] {
        guard !rawCards.isEmpty else { return [] }
        return rawCards
            .components(separatedBy: .whitespaces)
            .map { cardStr in
                let str = cardStr.prefix(cardStr.count - 1)
                let value: Int? = Int(str) ??
                    (str == "k" ? 13 : str == "q" ? 12 : str == "j" ? 11 : str == "a" ? 1 : nil)
                return Card(value!, Card.Suit(rawValue: cardStr.last!)!)
            }
    }
    
    private static func _validateDeck(_ board: Board, isFullDeck: Bool) {
        var allCards = Set<Card>()
        for (suitRawValue, value) in board.foundations {
            if value > 0 {
                for val in 1...value {
                    let card = Card(val, Card.Suit(rawValue: suitRawValue)!)
                    let (inserted, _) = allCards.insert(card)
                    assert(inserted, "Found duplicate card \(card) in foundations.")
                }
            }
        }

        for col in board.columns {
            for card in col {
                let (inserted, _) = allCards.insert(card)
                assert(inserted, "Found duplicate card \(card) in column.")
            }
        }

        for card in board.freeCells {
            if let card = card {
                let (inserted, _) = allCards.insert(card)
                assert(inserted, "Found duplicate card \(card) in free cells.")
            }
        }
 
        if isFullDeck {
            for suit in Card.Suit.all {
                for val in 1...13 {
                    let card = Card(val, suit)
                    assert(allCards.contains(card), "Missing \(card).")
                }
            }
        }
    }
}
