//
//  Day7.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-08.
//

import Foundation
import Algorithms

struct CrabSubmarine {
    var position: Int
}

extension Array where Element == CrabSubmarine {
    fileprivate func part1(at position: Int) -> Int {
        var fuel = 0
        for crab in self {
            fuel += abs(crab.position - position)
        }
        return fuel
    }
    fileprivate func part2(at position: Int) -> Int {
        var fuel = 0
        for crab in self {
            let distance = abs(crab.position - position)
            fuel += ((distance * (distance + 1)) / 2)
        }
        return fuel
    }
}

private func parse(input: String) throws -> [CrabSubmarine] {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: ",")
        .compactMap { Int($0, radix: 10).map { CrabSubmarine(position: $0) } }
}

struct Day7Puzzle1: Puzzle {
    private let crabs: [CrabSubmarine]
    
    init(contents: String) throws {
        crabs = try parse(input: contents)
    }
    
    func answer() throws -> String {
        guard let range = crabs
                .map(\.position)
                .minAndMax()
        else { throw AOCError.invalidInput }
        var best: (position: Int, fuel: Int)? = nil
        for i in range.min...range.max {
            let fuel = crabs.part1(at: i)
            if best?.fuel ?? .max > fuel {
                best = (position: i, fuel: fuel)
            }
        }
        return best!.fuel.description
    }
}

struct Day7Puzzle2: Puzzle {
    private let crabs: [CrabSubmarine]
    
    init(contents: String) throws {
        crabs = try parse(input: contents)
    }
    
    func answer() throws -> String {
        guard let range = crabs
                .map(\.position)
                .minAndMax()
        else { throw AOCError.invalidInput }
        var best: (position: Int, fuel: Int)? = nil
        for i in range.min...range.max {
            let fuel = crabs.part2(at: i)
            if best?.fuel ?? .max > fuel {
                best = (position: i, fuel: fuel)
            }
        }
        return best!.fuel.description
    }
}
