//
//  Day3.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-04.
//

import Foundation

extension Collection where Element == Bool {
    fileprivate var integer: UInt64 {
        var value: UInt64 = 0
        for bit in self {
            if bit {
                value |= 1
            }
            value <<= 1
        }
        value >>= 1
        return value
    }
}

private func parse(input: String) throws -> [[Bool]] {
    return try input
        .split(separator: "\n")
        .compactMap { line -> [Bool] in
            return try line.map {
                switch $0 {
                case "0": return false
                case "1": return true
                default: throw AOCError.invalidInput
                }
            }
        }
}

struct Day3Puzzle1: Puzzle {
    private let input: [[Bool]]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func answer() -> String {
        let count = input.first!.count
        var gamma = [Bool](repeating: false, count: count)
        var epsilon = [Bool](repeating: false, count: count)
        for i in 0..<count {
            let ones = input
                .map { $0[i] }
                .filter { $0 }
                .count
            let zeros = input.count - ones
            if ones > zeros {
                gamma[i] = true
                epsilon[i] = false
            } else {
                gamma[i] = false
                epsilon[i] = true
            }
        }
        return (gamma.integer * epsilon.integer)
            .description
    }
}

struct Day3Puzzle2: Puzzle {
    private let input: [[Bool]]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func find(_ matcher: (Int, Int) -> Bool) -> [Bool] {
        let count = input.first!.count
        var candidates = input
        for i in 0..<count {
            let ones = candidates
                .map { $0[i] }
                .filter { $0 }
                .count
            let zeros = candidates.count - ones
            let match = matcher(zeros, ones)
            candidates = candidates.filter { $0[i] == match }
            if candidates.count == 1 {
                break
            }
        }
        return candidates.first!
    }
    
    func answer() -> String {
        let scrubber = find { $1 >= $0 }
        let generator = find { $1 < $0 }
        return (generator.integer * scrubber.integer)
            .description
    }
}
