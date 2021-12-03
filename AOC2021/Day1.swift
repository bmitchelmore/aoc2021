//
//  Day1Puzzle1.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-01.
//

import Foundation

enum AOCError: Error {
    case invalidInput
}

extension Collection {
    var pairs: [(Element, Element)] {
        return Array(zip(self, self.dropFirst()))
    }
    var triples: [(Element, Element, Element)] {
        guard count > 2 else { return [] }
        var triples: [(Element, Element, Element)] = []
        var a = Array(self)
        var b = Array(self.dropFirst())
        var c = Array(self.dropFirst(2))
        while !a.isEmpty, !b.isEmpty, !c.isEmpty {
            triples.append((a.first!, b.first!, c.first!))
            a.removeFirst()
            b.removeFirst()
            c.removeFirst()
        }
        return triples
    }
}

private func parse(input: String) throws -> [Int] {
    return try input
        .split(separator: "\n")
        .map { input -> Int in
            guard let value = Int(input, radix: 10) else {
                throw AOCError.invalidInput
            }
            return value
        }
}

struct Day1Puzzle1: Puzzle {
    private let input: [Int]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func answer() -> String {
        return input
            .pairs
            .map { $0.1 - $0.0 }
            .filter { $0 > 0 }
            .count
            .description
    }
}

struct Day1Puzzle2: Puzzle {
    private let input: [Int]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func answer() -> String {
        return input
            .triples
            .map { $0.0 + $0.1 + $0.2 }
            .pairs
            .map { $0.1 - $0.0 }
            .filter { $0 > 0 }
            .count
            .description
    }
}
