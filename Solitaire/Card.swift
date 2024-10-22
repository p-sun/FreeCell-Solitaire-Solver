//
//  Card.swift
//  Solitaire
//
//  Created by Paige Sun on 10/22/24.
//

public struct Card: Hashable {
    public enum Suit: Character, CustomStringConvertible {
        case heart = "h"
        case diamond = "d"
        case spade = "s"
        case club = "c"

        static let all : [Suit] = [.heart, .diamond, .club, .spade]
        
        public var description: String {
            switch self {
            case .heart: return "♡"
            case .diamond: return "♢"
            case .club: return "♣"
            case .spade: return "♠"
            }
        }
        
        var oppositeSuit: Suit {
            switch self {
            case .heart: return .diamond
            case .diamond: return .heart
            case .club: return .spade
            case .spade: return .club
            }
        }
    }
    
    let value: Int
    let suit: Suit
    private let _isInRedEvenSequence: Bool
    
    public init(_ value: Int, _ suit: Suit) {
        self.value = value
        self.suit = suit
        let isRed = suit == .heart || suit == .diamond
        self._isInRedEvenSequence = isRed ? value % 2 == 0 : value % 2 != 0
    }
    
    var isRed: Bool {
        return suit == .heart || suit == .diamond
    }
    
    func canBeStackedOn(_ other: Card) -> Bool {
        return _isInRedEvenSequence == other._isInRedEvenSequence && value == (other.value - 1)
    }
    
    func isInSameSequence(_ other: Card) -> Bool {
        return _isInRedEvenSequence == other._isInRedEvenSequence
    }
}

extension Card: CustomStringConvertible {
    public var description: String {
        return "\(value)\(suit)"
    }
}
