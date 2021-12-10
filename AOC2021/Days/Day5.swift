//
//  Day5.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-05.
//

import Foundation

extension Collection where Element: Hashable {
    var set: Set<Element> {
        return Set(self)
    }
}

struct LineSpace {
    private var cells: [Position:Int] = [:]
    
    mutating func add(_ line: Line) {
        for position in line.coverage {
            if let value = cells[position] {
                cells[position] = value + 1
            } else {
                cells[position] = 1
            }
        }
    }
    
    func count(where predicate: (Int) -> Bool) -> Int {
        return cells
            .filter { predicate($0.value) }
            .count
    }
}

struct Position: Hashable {
    var x: Int
    var y: Int
}

struct Line {
    var start: Position
    var end: Position
    
    var isVertical: Bool {
        return start.x == end.x
    }
    
    var isHorizontal: Bool {
        return start.y == end.y
    }
    
    var coverage: Set<Position> {
        if isVertical {
            return (min(start.y, end.y)...max(start.y, end.y))
                .map { Position(x: start.x, y: $0) }
                .set
        }
        if isHorizontal {
            return (min(start.x, end.x)...max(start.x, end.x))
                .map { Position(x: $0, y: start.y) }
                .set
        }
        return zip(
                stride(from: start.x, through: end.x, by: start.x > end.x ? -1 : 1),
                stride(from: start.y, through: end.y, by: start.y > end.y ? -1 : 1)
            )
            .map { Position(x: $0, y: $1) }
            .set
    }
}

private func parse(input: String) throws -> [Line] {
    return input
        .components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .map { str -> Line in
            let positions = str
                .components(separatedBy: " -> ")
                .map { str -> Position in
                    let points = str
                        .components(separatedBy: ",")
                        .map { Int($0, radix: 10)! }
                    return Position(x: points[0], y: points[1])
                }
            return Line(start: positions[0], end: positions[1])
        }
}

struct Day5Puzzle1: Puzzle {
    private let lines: [Line]
    
    init(contents: String) throws {
        lines = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return lines
            .filter { $0.isVertical || $0.isHorizontal }
            .reduce(into: LineSpace()) { $0.add($1) }
            .count { $0 >= 2 }
            .description
    }
}

struct Day5Puzzle2: Puzzle {
    private let lines: [Line]
    
    init(contents: String) throws {
        lines = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return lines
            .reduce(into: LineSpace()) { $0.add($1) }
            .count { $0 >= 2 }
            .description
    }
}

