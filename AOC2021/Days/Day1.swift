//
//  Day1Puzzle1.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-01.
//

import Foundation
import Algorithms

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
            .adjacentPairs()
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
            .windows(ofCount: 3)
            .map { $0.reduce(0, +) }
            .adjacentPairs()
            .map { $0.1 - $0.0 }
            .filter { $0 > 0 }
            .count
            .description
    }
}
