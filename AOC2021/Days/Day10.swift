//
//  Day10.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-10.
//

import Foundation

private enum ValidationResult: Equatable {
    case valid
    case incomplete([ChunkMarker])
    case corrupted(ChunkMarker)
    
    var corruptedScore: Int? {
        switch self {
        case .valid, .incomplete:
            return nil
        case .corrupted(let chunkMarker):
            return chunkMarker.corruptedScore
        }
    }
    
    var remaining: [ChunkMarker]? {
        switch self {
        case .valid, .corrupted:
            return nil
        case .incomplete(let array):
            return array.reversed()
        }
    }
}

private enum ChunkMarker: Equatable, Hashable {
    case round
    case square
    case curly
    case angled
    
    init?(_ character: Character) {
        switch character {
        case "(", ")":
            self = .round
        case "[", "]":
            self = .square
        case "{", "}":
            self = .curly
        case "<", ">":
            self = .angled
        default:
            return nil
        }
    }
    
    var corruptedScore: Int {
        switch self {
        case .round:
            return 3
        case .square:
            return 57
        case .curly:
            return 1197
        case .angled:
            return 25137
        }
    }
    
    var incompleteScore: Int {
        switch self {
        case .round:
            return 1
        case .square:
            return 2
        case .curly:
            return 3
        case .angled:
            return 4
        }
    }
    
    var open: Character {
        switch self {
        case .round:
            return "("
        case .square:
            return "["
        case .curly:
            return "{"
        case .angled:
            return "<"
        }
    }
    
    var close: Character {
        switch self {
        case .round:
            return ")"
        case .square:
            return "]"
        case .curly:
            return "}"
        case .angled:
            return ">"
        }
    }
}

private func validate(line: String) -> ValidationResult {
    var stack: [ChunkMarker] = []
    for char in line {
        guard let marker = ChunkMarker(char) else { continue }
        if marker.open == char {
            stack.append(marker)
        } else if marker.close == char {
            guard !stack.isEmpty else {
                fatalError("Closing chunk with no opened chunk: \(char)")
            }
            let current = stack.removeLast()
            if current != marker {
                return .corrupted(marker)
            }
        } else {
            fatalError("Unknown state!")
        }
    }
    return stack.isEmpty ? .valid : .incomplete(stack)
}

extension Array {
    fileprivate var middle: Element? {
        return self[count / 2]
    }
}

private func parse(input: String) throws -> [String] {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespaces) }
}

struct Day10Puzzle1: Puzzle {
    private let lines: [String]
    
    init(contents: String) throws {
        lines = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return lines
            .map { validate(line: $0) }
            .compactMap { $0.corruptedScore }
            .reduce(0, +)
            .description
    }
}

struct Day10Puzzle2: Puzzle {
    private let lines: [String]
    
    init(contents: String) throws {
        lines = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return lines
            .map { validate(line: $0) }
            .compactMap { $0.remaining }
            .map { $0.reduce(0) { $0 * 5 + $1.incompleteScore } }
            .sorted()
            .middle!
            .description
    }
}
