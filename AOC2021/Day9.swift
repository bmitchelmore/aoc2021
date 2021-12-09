//
//  Day9.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-09.
//

import Foundation

private struct MapPosition: Hashable {
    var x: Int
    var y: Int
    
    var up: MapPosition {
        return MapPosition(x: x, y: y - 1)
    }
    var down: MapPosition {
        return MapPosition(x: x, y: y + 1)
    }
    var left: MapPosition {
        return MapPosition(x: x - 1, y: y)
    }
    var right: MapPosition {
        return MapPosition(x: x + 1, y: y)
    }
}

private struct HeightMap {
    var heights: [MapPosition:Int]
    
    var lowPoints: [(MapPosition, Int)] {
        return heights
            .filter { (key: MapPosition, value: Int) in
                let neighbours = [key.up, key.down, key.right, key.left].compactMap { heights[$0] }
                let filtered = neighbours.filter { $0 > value }
                return filtered.count == neighbours.count
            }
            .map { ($0.key, $0.value) }
    }
    
    private func grow(from point: MapPosition, using visited: inout [MapPosition:Bool]) -> Int {
        var total = 0
        if let height = heights[point], height != 9 {
            total += 1
            for neighbour in [point.up, point.down, point.right, point.left] where visited[neighbour] == nil {
                visited[neighbour] = true
                total += grow(from: neighbour, using: &visited)
            }
        }
        return total
    }
    
    func basinSize(for lowPoint: MapPosition) -> Int {
        var visited: [MapPosition:Bool] = [
            lowPoint: true
        ]
        return grow(from: lowPoint, using: &visited)
    }
}

private func parse(input: String) throws -> HeightMap {
    var heights: [MapPosition:Int] = [:]
    input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .enumerated()
        .forEach { (x, line) in
            line.enumerated().forEach { (y, char) in
                let height = Int(String(char), radix: 10)!
                heights[MapPosition(x: x, y: y)] = height
            }
        }
    return HeightMap(heights: heights)
}

struct Day9Puzzle1: Puzzle {
    private let map: HeightMap
    
    init(contents: String) throws {
        map = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return map
            .lowPoints
            .map { $0.1 + 1 }
            .reduce(0, +)
            .description
    }
}

struct Day9Puzzle2: Puzzle {
    private let map: HeightMap
    
    init(contents: String) throws {
        map = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return map
            .lowPoints
            .map { map.basinSize(for: $0.0) }
            .sorted()
            .suffix(3)
            .reduce(1, *)
            .description
    }
}
