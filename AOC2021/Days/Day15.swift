//
//  Day15.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-15.
//

import Foundation

private struct Position: Equatable, Hashable, CustomStringConvertible {
    var x: Int
    var y: Int
    
    var up: Position {
        return Position(x: x, y: y - 1)
    }
    var down: Position {
        return Position(x: x, y: y + 1)
    }
    var left: Position {
        return Position(x: x - 1, y: y)
    }
    var right: Position {
        return Position(x: x + 1, y: y)
    }
    var neighbours: [Position] {
        return [up, down, left, right]
    }
    
    var description: String {
        return "(\(x), \(y))"
    }
}

private typealias Risk = Int

private struct Cave {
    var risks: [Position:Risk]
    var size: Position
    
    init(risks: [Position:Risk]) {
        self.risks = risks
        self.size = risks.keys.max { a, b in
            if a.x == b.x {
                return a.y < b.y
            } else {
                return a.x < b.x
            }
        } ?? Position(x: 0, y: 0)
    }
}

extension Cave {
    class Node {
        let id: Position
        let weight: Int
        var neighbours: [Node]
        var distance: Int
        
        init(id: Position, weight: Int) {
            self.id = id
            self.weight = weight
            self.neighbours = []
            self.distance = .max
        }
        
        func connect(to neighbour: Node) {
            neighbours.append(neighbour)
        }
    }
    
    enum Source {
        case start
        
        func position(in cave: Cave) -> Position {
            return Position(x: 0, y: 0)
        }
    }
    
    enum Destination {
        case end
        
        func position(in cave: Cave) -> Position {
            return cave.size
        }
    }
    
    func path(from src: Source, to dest: Destination) -> Int {
        let start = src.position(in: self)
        let end = dest.position(in: self)
        var nodes: [Position:Node] = [:]
        for (key, value) in risks {
            nodes[key] = Node(id: key, weight: value)
        }
        for node in nodes.values {
            for potential in node.id.neighbours {
                guard let neighbour = nodes[potential] else { continue }
                node.connect(to: neighbour)
            }
        }
        nodes[start]!.distance = 0
        
        // using a plain array here even though
        // a priority queue would be better because
        // there are no good standard implementations
        // yet and I don't want to spend time
        // implementing one myself
        var queue = [nodes[start]!]
        while true {
            guard let current = queue.first else {
                break
            }
            queue.removeFirst()
            for neighbour in current.neighbours {
                let distance = current.distance + neighbour.weight
                if neighbour.distance > distance {
                    neighbour.distance = distance
                    queue.append(neighbour)
                }
            }
            queue.sort { a, b in
                a.distance < b.distance
            }
        }
        return nodes[end]!.distance
    }
}

extension Cave {
    var expanded: Cave {
        var updated: [Position:Int] = [:]
        for y in 0...size.y {
            for x in 0...size.x {
                for i in 0..<5 {
                    for j in 0..<5 {
                        let base = Position(x: x, y: y)
                        let position = Position(x: x + (size.x + 1) * i, y: y + (size.y + 1) * j)
                        let original = risks[base]!
                        var adjusted = original + i + j
                        while adjusted > 9 {
                            adjusted -= 9
                        }
                        updated[position] = adjusted
                    }
                }
            }
        }
        return Cave(risks: updated)
    }
}

private func parse(input: String) throws -> Cave {
    var values: [Position:Risk] = [:]
    input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .enumerated()
        .forEach { (y, line) in
            line
                .trimmingCharacters(in: .whitespaces)
                .enumerated()
                .forEach { (x, c) in
                    values[Position(x: x, y: y)] = Int(String(c), radix: 10)!
                }
        }
    return Cave(risks: values)
}

struct Day15Puzzle1: Puzzle {
    private let cave: Cave

    init(contents: String) throws {
        cave = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return cave
            .path(from: .start, to: .end)
            .description
    }
}

struct Day15Puzzle2: Puzzle {
    private let cave: Cave

    init(contents: String) throws {
        cave = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return cave
            .expanded
            .path(from: .start, to: .end)
            .description
    }
}
