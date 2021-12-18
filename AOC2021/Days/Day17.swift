//
//  Day17.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-17.
//

import Foundation

private typealias ProbeTargetRange = (x: ClosedRange<Int>, y: ClosedRange<Int>)

private struct Velocity: CustomStringConvertible {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var description: String {
        return "(\(x), \(y))"
    }
}

private struct Position {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    mutating func apply(_ velocity: inout Velocity) {
        x += velocity.x
        y += velocity.y
        if velocity.x > 0 {
            velocity.x -= 1
        } else if velocity.x < 0 {
            velocity.x += 1
        }
        velocity.y -= 1
    }
    
    func within(_ range: ProbeTargetRange) -> Bool {
        return range.x.contains(x) && range.y.contains(y)
    }
    
    func beyond(_ range: ProbeTargetRange) -> Bool {
        return x > range.x.upperBound || y < range.y.lowerBound
    }
}

private struct ProbePath {
    var position: Position = Position(0, 0)
    var velocity: Velocity
}

extension ProbePath: Sequence {
    func makeIterator() -> ProbePathIterator {
        return ProbePathIterator(position, velocity)
    }
}

private struct ProbePathIterator: IteratorProtocol {
    typealias Element = Position
    
    private var position: Position
    private var velocity: Velocity
    
    init(_ position: Position, _ velocity: Velocity) {
        self.position = position
        self.velocity = velocity
    }
    
    mutating func next() -> Position? {
        position.apply(&velocity)
        return position
    }
}

private struct VelocityOptions {
    private var range: ProbeTargetRange
    
    init(_ range: ProbeTargetRange) {
        self.range = range
    }
}

extension VelocityOptions: Sequence {
    func makeIterator() -> VelocityOptionsIterator {
        return VelocityOptionsIterator(range)
    }
}

private struct VelocityOptionsIterator: IteratorProtocol {
    typealias Element = Velocity
    
    private var range: ProbeTargetRange
    private var minx: Int
    private var maxx: Int
    private var miny: Int
    private var maxy: Int
    private var x: Int
    private var y: Int
    
    init(_ range: ProbeTargetRange) {
        self.range = range
        self.minx = (1...).first(where: { $0.triangular > range.x.lowerBound })!
        self.maxx = range.x.upperBound
        self.miny = range.y.lowerBound
        self.maxy = abs(range.y.lowerBound)
        self.x = minx
        self.y = miny
    }
    
    mutating func next() -> Velocity? {
        guard y <= maxy else { return nil }
        let velocity = Velocity(x, y)
        x += 1
        if x > maxx {
            x = minx
            y += 1
        }
        return velocity
    }
}

extension Int {
    var triangular: Int {
        return (self * (self + 1)) / 2
    }
}

private func parse(_ range: String) -> ClosedRange<Int> {
    let values = range.split(separator: ".")
        .compactMap { Int($0, radix: 10) }
    let a = values[0]
    let b = values[1]
    return a...b
}

private func parse(input: String) throws -> ProbeTargetRange {
    var line = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
    if line.hasPrefix("target area: ") {
        line.removeFirst(13)
    }
    var x: ClosedRange<Int> = 0...0
    var y: ClosedRange<Int> = 0...0
    line.components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .map { $0.components(separatedBy: "=") }
        .map { ($0[0], $0[1]) }
        .forEach { (axis, range) in
            switch axis {
            case "x":
                x = parse(range)
            case "y":
                y = parse(range)
            default: fatalError("Unknown axis: \(axis)")
            }
        }
    return (x, y)
}

struct Day17Puzzle1: Puzzle {
    private let range: ProbeTargetRange

    init(contents: String) throws {
        range = try parse(input: contents)
    }
    
    func answer() throws -> String {
        let start = Position(0, 0)
        var highest: (Velocity, Int)? = nil
        for velocity in VelocityOptions(range) {
            var apex = Int.min
            for position in ProbePath(position: start, velocity: velocity) {
                if apex < position.y {
                    apex = position.y
                }
                if position.within(range) {
                    if highest?.1 ?? .min < apex {
                        highest = (velocity, apex)
                    }
                    break
                } else if position.beyond(range) {
                    break
                }
            }
        }
        return highest!.1.description
    }
}

struct Day17Puzzle2: Puzzle {
    private let range: ProbeTargetRange

    init(contents: String) throws {
        range = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return VelocityOptions(range)
            .filter { velocity in
                let end: Position? = ProbePath(position: Position(0, 0), velocity: velocity).first { position in
                    position.within(range) || position.beyond(range)
                }
                return end!.within(range)
            }
            .count
            .description
    }
}
