//
//  Day21.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-21.
//

import Foundation

private struct DeterministicDie {
    var current = 0
    var rolls = 0
    
    mutating func next() -> Int {
        rolls += 1
        let output = current + 1
        current = (current + 1) % 100
        return output
    }
}

private struct Player: Equatable, Hashable {
    var position: Int
    var score: Int = 0
    
    var place: Int {
        return position + 1
    }
}

extension Player {
    mutating func move(forward: Int) {
        position = (position + forward) % 10
        score += place
    }
}

private struct Game {
    var players: [Player]
    var die = DeterministicDie()
    var currentPlayer: Int = 0
    var turns: Int = 0
    
    var over: Bool {
        return !players
            .filter { $0.score >= 1000 }
            .isEmpty
    }
    var losingScore: Int {
        return players
            .min { $0.score < $1.score }
            .unsafelyUnwrapped
            .score
    }
}

extension Game {
    mutating func play() {
        turns += 1
        let (a, b, c) = (die.next(), die.next(), die.next())
        let forward = a + b + c
        players[currentPlayer].move(forward: forward)
        currentPlayer = (currentPlayer + 1) % players.count
    }
}

private struct GameState: Equatable, Hashable {
    var p1: Player
    var p2: Player
    
    var over: Bool {
        p1.score >= 21 || p2.score >= 21
    }
}

private enum GameTurn {
    case one
    case two
    
    mutating func toggle() {
        switch self {
        case .one: self = .two
        case .two: self = .one
        }
    }
}

private struct QuantumGame {
    var players: [Player]
    var turn: GameTurn = .one
    var states: [GameState:UInt64] = [:]
    
    init(players: [Player]) {
        assert(players.count == 2)
        self.players = players
        self.states = [GameState(p1: players[0], p2: players[1]): 1]
    }
    
    var over: Bool {
        return states.keys.allSatisfy(\.over)
    }
}

extension QuantumGame {
    mutating func play() {
        var updated: [GameState: UInt64] = [:]
        let rolls: [(Int, Int, Int)] = [
            (1, 1, 1),
            (1, 1, 2),
            (1, 1, 3),
            (1, 2, 1),
            (1, 2, 2),
            (1, 2, 3),
            (1, 3, 1),
            (1, 3, 2),
            (1, 3, 3),
            (2, 1, 1),
            (2, 1, 2),
            (2, 1, 3),
            (2, 2, 1),
            (2, 2, 2),
            (2, 2, 3),
            (2, 3, 1),
            (2, 3, 2),
            (2, 3, 3),
            (3, 1, 1),
            (3, 1, 2),
            (3, 1, 3),
            (3, 2, 1),
            (3, 2, 2),
            (3, 2, 3),
            (3, 3, 1),
            (3, 3, 2),
            (3, 3, 3)
        ]
        let active = states.filter { !$0.key.over }
        let inactive = states.filter { $0.key.over }
        for (state, count) in inactive {
            updated[state] = count
        }
        for roll in rolls {
            let forward = roll.0 + roll.1 + roll.2
            for (var state, count) in active {
                switch turn {
                case .one:
                    state.p1.move(forward: forward)
                case .two:
                    state.p2.move(forward: forward)
                }
                if let existing = updated[state] {
                    updated[state] = existing + count
                } else {
                    updated[state] = count
                }
            }
        }
        turn.toggle()
        states = updated
    }
}

private func parse(input: String) throws -> [Player] {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .map { Int($0.dropFirst(28), radix: 10)! }
        .map { Player(position: $0 - 1) }
}

struct Day21Puzzle1: Puzzle {
    private let players: [Player]
    
    init(contents: String) throws {
        players = try parse(input: contents)
    }
    
    func answer() -> String {
        var game = Game(players: players)
        while !game.over {
            game.play()
        }
        let value = game.die.rolls * game.losingScore
        return value.description
    }
}

struct Day21Puzzle2: Puzzle {
    private let players: [Player]
    
    init(contents: String) throws {
        players = try parse(input: contents)
    }
    
    func answer() -> String {
        var game = QuantumGame(players: players)
        while !game.over {
            game.play()
        }
        let p1 = game.states
            .filter {
                $0.key.p1.score > $0.key.p2.score
            }
            .reduce(0) { $0 + $1.value }
        let p2 = game.states
            .filter {
                $0.key.p2.score > $0.key.p1.score
            }
            .reduce(0) { $0 + $1.value }
        return max(p1, p2).description
    }
}
