//
//  Day20.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-20.
//

import Foundation

private struct Algorithm {
    var outputs: [Bool]
}

private struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
    
    var surroundings: [Position] {
        return [
            Position(x: x - 1, y: y - 1),
            Position(x: x, y: y - 1),
            Position(x: x + 1, y: y - 1),
            Position(x: x - 1, y: y),
            Position(x: x, y: y),
            Position(x: x + 1, y: y),
            Position(x: x - 1, y: y + 1),
            Position(x: x, y: y + 1),
            Position(x: x + 1, y: y + 1)
        ]
    }
}

private struct Image {
    var pixels: [Position:Bool]
    var outbound: Bool = false
}

extension Image {
    var lit: Int {
        return pixels.filter(\.value).count
    }
}

extension Image: CustomStringConvertible {
    var description: String {
        let x = pixels.keys.minAndMax { a, b in
            a.x < b.x
        }
        let y = pixels.keys.minAndMax { a, b in
            a.y < b.y
        }
        guard let x = x, let y = y else { return "" }
        var result = "\n"
        for y in (y.min.y-1)...(y.max.y+1) {
            for x in (x.min.x-1)...(x.max.x+1) {
                switch pixels[Position(x: x, y: y)] ?? outbound {
                case true: result += "#"
                case false: result += "."
                }
            }
            result += "\n"
        }
        return result
    }
}

extension Image {
    mutating func apply(_ algorithm: Algorithm) {
        var locations: Set<Position> = Set(pixels.keys)
        locations.formUnion(pixels.flatMap(\.key.surroundings))
        var updated: [Position:Bool] = [:]
        for location in locations {
            var index = 0
            for location in location.surroundings {
                let b = pixels[location] ?? outbound
                index |= (b ? 1 : 0)
                index <<= 1
            }
            index >>= 1
            updated[location] = algorithm.outputs[index]
        }
        var index = (0..<9).reduce(0) { (curr, _) in
            var updated = curr | (outbound ? 1 : 0)
            updated <<= 1
            return updated
        }
        index >>= 1
        
        outbound = algorithm.outputs[index]
        pixels = updated
    }
}

extension Bool {
    fileprivate init(char: Character) {
        switch char {
        case "#": self = true
        case ".": self = false
        default: fatalError("Unknown character: \(char)")
        }
    }
}

private func parse(input: String) throws -> (Algorithm, Image) {
    var lines = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
    var values: [Bool] = []
    while true {
        let line = lines.removeFirst()
        guard !line.isEmpty else { break }
        let bools = line.map(Bool.init(char:))
        values.append(contentsOf: bools)
    }
    var pixels: [Position:Bool] = [:]
    for (y, line) in lines.enumerated() {
        for (x, c) in line.enumerated() {
            let b = Bool(char: c)
            let p = Position(x: x, y: y)
            pixels[p] = b
        }
    }
    return (
        Algorithm(outputs: values),
        Image(pixels: pixels)
    )
}

struct Day20Puzzle1: Puzzle {
    private let algorithm: Algorithm
    private let image: Image
    
    init(contents: String) throws {
        (algorithm, image) = try parse(input: contents)
    }
    
    func answer() -> String {
        return (0..<2)
            .reduce(into: image) { image, _ in
                image.apply(algorithm)
            }
            .lit
            .description
    }
}

struct Day20Puzzle2: Puzzle {
    private let algorithm: Algorithm
    private let image: Image
    
    init(contents: String) throws {
        (algorithm, image) = try parse(input: contents)
    }
    
    func answer() -> String {
        return (0..<50)
            .reduce(into: image) { image, _ in
                image.apply(algorithm)
            }
            .lit
            .description
    }
}
