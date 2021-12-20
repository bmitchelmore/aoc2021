//
//  Day19.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-19.
//

import Foundation

private enum Turn: Int, CaseIterable {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
}

private struct Orientation: Equatable, Hashable {
    var x: Turn
    var y: Turn
    var z: Turn
}

extension Orientation {
    static var allCases: [Orientation] {
        var orientations: [Orientation] = []
        for x in Turn.allCases {
            for y in Turn.allCases {
                for z in Turn.allCases {
                    orientations.append(Orientation(x: x, y: y, z: z))
                }
            }
        }
        return orientations
    }
}

extension Orientation: CustomStringConvertible {
    var description: String {
        return "x:\(String(repeating:"⮐", count: x.rawValue)), y:\(String(repeating:"⮐", count: y.rawValue)), z:\(String(repeating:"⮐", count: z.rawValue))"
    }
}

private struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
    var z: Int
}

extension Position: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y), \(z))"
    }
}

extension Position {
    static func -(lhs: Position, rhs: Position) -> Position {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        let z = lhs.z - rhs.z
        return Position(x: x, y: y, z: z)
    }
    static func +(lhs: Position, rhs: Position) -> Position {
        let x = lhs.x + rhs.x
        let y = lhs.y + rhs.y
        let z = lhs.z + rhs.z
        return Position(x: x, y: y, z: z)
    }
}

extension Position {
    private mutating func transform(_ mx: [[Double]]) {
        assert(mx.count == 3)
        assert(mx.allSatisfy({ $0.count == 3 }))
        var result: [Int] = []
        for row in mx {
            var value: Int = 0
            for (x, m) in zip([x, y, z], row) {
                value += Int(m * Double(x))
            }
            result.append(value)
        }
        x = result[0]
        y = result[1]
        z = result[2]
    }
    private mutating func rotate(x turns: Turn) {
        let theta = Double(turns.rawValue) * .pi / 2
        let mx = [
            [1, 0, 0],
            [0, cos(theta), -sin(theta)],
            [0, sin(theta), cos(theta)]
        ]
        transform(mx)
    }
    private mutating func rotate(y turns: Turn) {
        let theta = Double(turns.rawValue) * .pi / 2
        let mx = [
            [cos(theta), 0, sin(theta)],
            [0, 1, 0],
            [-sin(theta), 0, cos(theta)]
        ]
        transform(mx)
    }
    private mutating func rotate(z turns: Turn) {
        let theta = Double(turns.rawValue) * .pi / 2
        let mx = [
            [cos(theta), -sin(theta), 0],
            [sin(theta), cos(theta), 0],
            [0, 0, 1]
        ]
        transform(mx)
    }
    mutating func orient(to orientation: Orientation) {
        rotate(x: orientation.x)
        rotate(y: orientation.y)
        rotate(z: orientation.z)
    }
    func distance(from other: Position) -> Int {
        let offset = other - self
        return abs(offset.x) + abs(offset.y) + abs(offset.z)
    }
}

private struct Beacon: Equatable, Hashable {
    var position: Position
}

extension Beacon: CustomStringConvertible {
    var description: String {
        return position.description
    }
}

extension Beacon {
    static func -(lhs: Beacon, rhs: Beacon) -> Position {
        return lhs.position - rhs.position
    }
    static func +(lhs: Beacon, rhs: Position) -> Beacon {
        return Beacon(position: lhs.position + rhs)
    }
}

extension Beacon {
    init(string: String) {
        let parts = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ",")
        assert(parts.count == 3)
        let x = Int(parts[0], radix: 10)!
        let y = Int(parts[1], radix: 10)!
        let z = Int(parts[2], radix: 10)!
        self = Beacon(position: Position(x: x, y: y, z: z))
    }
}

extension Beacon {
    func oriented(to orientation: Orientation) -> Beacon {
        var copy = self
        copy.position.orient(to: orientation)
        return copy
    }
    func distance(from other: Beacon) -> Int {
        let offset = other.position - self.position
        return offset.x + offset.y + offset.z
    }
}


private struct Scanner {
    var position: Position = Position(x: 0, y: 0, z: 0)
    var beacons: Set<Beacon>
}

extension Scanner {
    mutating func include(_ other: Scanner) {
        for beacon in other.beacons {
            beacons.insert(beacon)
        }
    }
    mutating func orient(to orientation: Orientation) {
        let transformed = beacons.map { $0.oriented(to: orientation) }
        beacons = Set(transformed)
    }
    func oriented(to orientation: Orientation) -> Scanner {
        var copy = self
        copy.orient(to: orientation)
        return copy
    }
    mutating func translate(by offset: Position) {
        let transformed = beacons.map { $0 + offset }
        beacons = Set(transformed)
    }
    func translated(by offset: Position) -> Scanner {
        var copy = self
        copy.translate(by: offset)
        return copy
    }
    func relation(with other: Scanner) -> (Orientation,Position)? {
        var ranks: [Orientation: Int] = [:]
        var differences: [Position:(Beacon, Beacon)] = [:]
        for pair in beacons.permutations(ofCount: 2) {
            let a = pair.first!
            let b = pair.last!
            let diff = b - a
            differences[diff] = (a, b)
        }
        for orientation in Orientation.allCases {
            let other = other.oriented(to: orientation)
            var otherDifferences: [Position:(Beacon, Beacon)] = [:]
            for pair in other.beacons.permutations(ofCount: 2) {
                let a = pair.first!
                let b = pair.last!
                let diff = b - a
                otherDifferences[diff] = (a, b)
            }
            let intersection = Set(otherDifferences.keys).intersection(differences.keys)
            ranks[orientation] = intersection.count
        }
        let best = ranks
            .sorted { a, b in
                a.value > b.value
            }
            .first
        guard let best = best else { return nil }
        
        let other = other.oriented(to: best.key)
        var otherDifferences: [Position:(Beacon, Beacon)] = [:]
        for pair in other.beacons.permutations(ofCount: 2) {
            let a = pair.first!
            let b = pair.last!
            let diff = b - a
            otherDifferences[diff] = (a, b)
        }
        var offsets: Set<Position> = []
        for (key, value) in differences {
            if let other = otherDifferences[key] {
                offsets.insert(value.0 - other.0)
            }
        }
        guard let offset = offsets.first else {
            return nil
        }
        
        return (best.key, offset)
    }
}

private func parse(input: String) throws -> [Scanner] {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.starts(with: "--- scanner ") else {
        throw AOCError.invalidInput
    }
    var scanners: [[String]] = []
    var beacons: [String] = []
    trimmed.components(separatedBy: .newlines)
        .dropFirst()
        .forEach { line in
            if line.starts(with: "--- scanner ") {
                scanners.append(beacons)
                beacons = []
            } else if !line.isEmpty {
                beacons.append(line)
            }
        }
    if !beacons.isEmpty {
        scanners.append(beacons)
    }
    
    return scanners.map { beacons in
        let beacons = beacons.map(Beacon.init(string:))
        return Scanner(beacons: Set(beacons))
    }
}

struct Day19Puzzle1: Puzzle {
    private let scanners: [Scanner]

    init(contents: String) throws {
        scanners = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var base = scanners.first!
        var pending = scanners.dropFirst()
        var skips = 0
        while !pending.isEmpty {
            var unmatched = pending.removeFirst()
            guard let (orientation, offset) = base.relation(with: unmatched) else {
                skips += 1
                pending.append(unmatched)
                if skips > pending.count {
                    throw AOCError.unknownAnswer
                } else {
                    continue
                }
            }
            skips = 0
            
            unmatched.orient(to: orientation)
            unmatched.translate(by: offset)
            base.include(unmatched)
        }
        return base.beacons.count.description
    }
}

struct Day19Puzzle2: Puzzle {
    private let scanners: [Scanner]

    init(contents: String) throws {
        scanners = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var base = scanners.first!
        var adjusted: [Scanner] = [base]
        var pending = scanners.dropFirst()
        var skips = 0
        while !pending.isEmpty {
            var unmatched = pending.removeFirst()
            guard let (orientation, offset) = base.relation(with: unmatched) else {
                skips += 1
                pending.append(unmatched)
                if skips > pending.count {
                    throw AOCError.unknownAnswer
                } else {
                    continue
                }
            }
            skips = 0
            
            unmatched.orient(to: orientation)
            unmatched.translate(by: offset)
            unmatched.position = offset
            adjusted.append(unmatched)
            base.include(unmatched)
        }
        
        let max = adjusted
            .permutations(ofCount: 2)
            .map { $0.first!.position.distance(from: $0.last!.position) }
            .max()
        guard let max = max else {
            throw AOCError.unknownAnswer
        }

        return max.description
    }
}
