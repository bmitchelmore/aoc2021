//
//  Day13.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-13.
//

import Foundation

private struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
}

private enum Fold {
    case vertical(Int)
    case horizontal(Int)
}

private struct Grid {
    var dots: Set<Position>
    
    func folding(_ fold: Fold) -> Grid {
        var copy = self
        copy.fold(fold)
        return copy
    }
    
    mutating func fold(_ fold: Fold) {
        switch fold {
        case .vertical(let x):
            let next: Set<Position> = dots.reduce(into: Set()) { dots, dot in
                if dot.x > x {
                    dots.insert(Position(x: x - (dot.x - x), y: dot.y))
                } else {
                    dots.insert(dot)
                }
            }
            dots = next
        case .horizontal(let y):
            let next: Set<Position> = dots.reduce(into: Set()) { dots, dot in
                if dot.y > y {
                    dots.insert(Position(x: dot.x, y: y - (dot.y - y)))
                } else {
                    dots.insert(dot)
                }
            }
            dots = next
        }
    }
}

extension Grid: CustomStringConvertible {
    var description: String {
        var result = ""
        guard
            let width = dots.max(by: { $0.x < $1.x })?.x,
            let height = dots.max(by: { $0.y < $1.y })?.y
        else { return result }
        for y in 0...height {
            for x in 0...width {
                switch dots.contains(Position(x: x, y: y)) {
                case true: result.append("#")
                case false: result.append(" ")
                }
            }
            result.append("\n")
        }
        return result
    }
}

extension String {
    fileprivate func prepending(_ string: String) -> String {
        return "\(string)\(self)"
    }
}

private func parse(input: String) throws -> (Grid, [Fold]) {
    let parts = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n\n")
    assert(parts.count == 2)
    let dots: Set<Position> = parts[0]
        .components(separatedBy: .newlines)
        .reduce(into: Set()) { (positions, line) in
            let values = line.split(separator: ",")
            assert(values.count == 2)
            guard
                let x = Int(values[0], radix: 10),
                let y = Int(values[1], radix: 10)
            else { return }
            let position = Position(x: x, y: y)
            positions.insert(position)
        }
    let folds: [Fold] = parts[1]
        .components(separatedBy: .newlines)
        .compactMap { line in
            guard line.starts(with: "fold along ") else {
                return nil
            }
            let instruction = line.dropFirst(11)
            let parts = instruction.components(separatedBy: "=")
            assert(parts.count == 2)
            guard let value = Int(parts[1], radix: 10) else { return nil }
            switch parts[0] {
            case "x":
                return .vertical(value)
            case "y":
                return .horizontal(value)
            default:
                return nil
            }
        }
    return (Grid(dots: dots), folds)
}

struct Day13Puzzle1: Puzzle {
    private let grid: Grid
    private let folds: [Fold]

    init(contents: String) throws {
        (grid, folds) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return grid
            .folding(folds.first!)
            .dots.count
            .description
    }
}

struct Day13Puzzle2: Puzzle {
    private let grid: Grid
    private let folds: [Fold]
    
    init(contents: String) throws {
        (grid, folds) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return folds
            .reduce(grid) { $0.folding($1) }
            .description
            .prepending("\n")
    }
}
