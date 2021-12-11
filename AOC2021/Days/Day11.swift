//
//  Day11.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-11.
//

import Foundation

private struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
}

private struct Octopi {
    var octopi: [Position:Octopus]
    
    var synchronized: Bool {
        return octopi
            .compactMapValues { $0.wasFlashing }
            .values
            .allSatisfy { $0 }
    }
    
    private mutating func flash(_ pos: Position) -> Int {
        var total = 0
        for x in pos.x-1...pos.x+1 {
            for y in pos.y-1...pos.y+1 {
                let neighbour = Position(x: x, y: y)
                guard neighbour != pos else { continue }
                total += energize(neighbour)
            }
        }
        return total
    }
    
    private mutating func energize(_ pos: Position) -> Int {
        if octopi[pos]?.energize() ?? false {
            return 1 + flash(pos)
        }
        return 0
    }
    
    @discardableResult
    mutating func elapse() -> Int {
        var total = 0
        for pos in octopi.keys {
            total += energize(pos)
        }
        for pos in octopi.keys {
            octopi[pos]!.reset()
        }
        return total
    }
}

private struct Octopus {
    var energy: Int
    
    var isFlashing: Bool {
        return energy > 9
    }
    
    var wasFlashing: Bool {
        return energy == 0
    }
    
    mutating func reset() {
        if isFlashing {
            energy = 0
        }
    }
    
    mutating func energize() -> Bool {
        let wasFlashing = isFlashing
        energy += 1
        return !wasFlashing && isFlashing
    }
}

private func parse(input: String) throws -> Octopi {
    var octopi: [Position:Octopus] = [:]
    input.trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .enumerated()
        .forEach { (x, line) in
            line
                .trimmingCharacters(in: .whitespaces)
                .compactMap { Int(String($0), radix: 10) }
                .enumerated()
                .forEach { (y, energy) in
                    octopi[Position(x: x, y: y)] = Octopus(energy: energy)
                }
        }
    return Octopi(octopi: octopi)
}

struct Day11Puzzle1: Puzzle {
    private let octopi: Octopi
    
    init(contents: String) throws {
        octopi = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var octopi = self.octopi
        return (1...100)
            .map { _ in octopi.elapse() }
            .reduce(0, +)
            .description
    }
}

struct Day11Puzzle2: Puzzle {
    private let octopi: Octopi
    
    init(contents: String) throws {
        octopi = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var octopi = self.octopi
        var i = 0
        while !octopi.synchronized {
            i += 1
            octopi.elapse()
        }
        return i.description
    }
}
