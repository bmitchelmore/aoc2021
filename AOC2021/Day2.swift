//
//  Day2.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-02.
//

import Foundation

enum Day2Command {
    case forward(Int)
    case down(Int)
    case up(Int)
}

struct Day2Position {
    var position: Int
    var depth: Int
    var aim: Int
    
    init() {
        self.position = 0
        self.depth = 0
        self.aim = 0
    }
    
    mutating func part1(_ command: Day2Command) {
        switch command {
        case .forward(let value):
            position += value
        case .down(let value):
            depth += value
        case .up(let value):
            depth -= value
        }
    }
    
    mutating func part2(_ command: Day2Command) {
        switch command {
        case .forward(let value):
            position += value
            depth +=  aim * value
        case .down(let value):
            aim += value
        case .up(let value):
            aim -= value
        }
    }
    
    var value: Int {
        return position * depth
    }
}

private func parse(input: String) throws -> [Day2Command] {
    return input
        .split(separator: "\n")
        .compactMap { line -> Day2Command? in
            let parts = line.split(separator: " ")
            guard parts.count > 1 else { return nil }
            guard let value = Int(parts[1], radix: 10) else { return nil }
            switch parts[0] {
            case "forward":
                return .forward(value)
            case "down":
                return .down(value)
            case "up":
                return .up(value)
            default:
                return nil
            }
        }
}

struct Day2Puzzle1: Puzzle {
    private let input: [Day2Command]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func answer() -> String {
        return input
            .reduce(into: Day2Position()) { position, command in
                position.part1(command)
            }
            .value
            .description
    }
}

struct Day2Puzzle2: Puzzle {
    private let input: [Day2Command]
    
    init(contents: String) throws {
        input = try parse(input: contents)
    }
    
    func answer() -> String {
        return input
            .reduce(into: Day2Position()) { position, command in
                position.part2(command)
            }
            .value
            .description
    }
}

