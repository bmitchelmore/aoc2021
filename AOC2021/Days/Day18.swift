//
//  Day18.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-18.
//

import Foundation
import AppKit
import Collections

private indirect enum Either<A, B> {
    case left(A)
    case right(B)
}

extension Either: CustomStringConvertible {
    var description: String {
        switch self {
        case .left(let left):
            return "\(left)"
        case .right(let right):
            return "\(right)"
        }
    }
}

private struct SnailfishNumber {
    var depth: Int {
        didSet {
            switch first {
            case .left(var left):
                left.depth = depth + 1
                self.first = .left(left)
            default: break
            }
            switch second {
            case .left(var right):
                right.depth = depth + 1
                self.second = .left(right)
            default: break
            }
        }
    }
    var first: Either<SnailfishNumber, Int>
    var second: Either<SnailfishNumber, Int>
}

private enum ParseState {
    case left
    case right
}

private func capture(_ string: String) -> Either<(String,String),String> {
    var depth = 0
    var left = ""
    var right = ""
    var readingLeft = true
    let append: (Character) -> Void = { c in
        if readingLeft {
            left.append(c)
        } else {
            right.append(c)
        }
    }
    for c in string {
        switch c {
        case "[":
            if depth != 0 {
                append(c)
            }
            depth += 1
        case "]":
            depth -= 1
            if depth != 0 {
                append(c)
            }
            if depth == 0 {
                return .left((left, right))
            }
        case ",":
            if depth == 1 {
                readingLeft = false
            } else if depth > 1 {
                append(c)
            }
        default:
            append(c)
        }
    }
    
    return .right(string)
}

private func parse(_ string: String, depth: Int) -> Either<SnailfishNumber, Int> {
    let captured = capture(string)
    switch captured {
    case .left((let left, let right)):
        return .left(SnailfishNumber(
            depth: depth,
            first: parse(left, depth: depth + 1),
            second: parse(right, depth: depth + 1)
        ))
    case .right(let str):
        return .right(Int(str, radix: 10)!)
    }
}

extension SnailfishNumber {
    init(from string: String) {
        switch capture(string) {
        case .right:
            fatalError("Unknown number: \(string)")
        case .left((let left, let right)):
            self.depth = 0
            self.first = parse(left, depth: 0)
            self.second = parse(right, depth: 0)
        }
    }
}

extension SnailfishNumber: CustomStringConvertible {
    var description: String {
        return "[\(first),\(second)]"
    }
}

extension SnailfishNumber {
    var shouldExplode: Bool {
        switch (first, second) {
        case (.right, .right):
            return depth >= 4
        default:
            return false
        }
    }
}

extension SnailfishNumber {
    var deeper: SnailfishNumber {
        var copy = self
        copy.depth += 1
        return copy
    }
    mutating func add(_ other: SnailfishNumber) {
        self = SnailfishNumber(
            depth: 0,
            first: .left(self.deeper),
            second: .left(other.deeper)
        )
        self.reduce()
    }
    private mutating func add(value: Int, key: WritableKeyPath<SnailfishNumber,Either<SnailfishNumber,Int>>, add: (inout SnailfishNumber, Int) -> Bool) -> Bool {
        switch self[keyPath: key] {
        case .right(let number):
            self[keyPath: key] = .right(number + value)
            return true
        case .left(var pair):
            let added = add(&pair, value)
            self[keyPath: key] = .left(pair)
            return added
        }
    }
    mutating func add(left: Int) -> Bool {
        if add(value: left, key: \.first, add: { $0.add(left: $1) }) {
            return true
        }
        if add(value: left, key: \.second, add: { $0.add(left: $1) }) {
            return true
        }
        return false
    }
    mutating func add(right: Int) -> Bool {
        if add(value: right, key: \.second, add: { $0.add(right: $1) }) {
            return true
        }
        if add(value: right, key: \.first, add: { $0.add(right: $1) }) {
            return true
        }
        return false
    }
}

extension SnailfishNumber {
    var magnitude: Int {
        let left: Int
        let right: Int
        switch first {
        case .left(let pair):
            left = pair.magnitude
        case .right(let number):
            left = number
        }
        switch second {
        case .left(let pair):
            right = pair.magnitude
        case .right(let number):
            right = number
        }
        return (3 * left) + (2 * right)
    }
}

extension Int {
    fileprivate var shouldSplit: Bool {
        return self >= 10
    }
}

extension SnailfishNumber {
    enum ReduceAction: Equatable {
        case none
        case explode(Int, Int)
        case split(Int)
    }
    
    private mutating func explode(_ key: WritableKeyPath<SnailfishNumber,Either<SnailfishNumber, Int>>) -> ReduceAction {
        switch self[keyPath: key] {
        case .left(let pair) where pair.shouldExplode:
            switch (pair.first, pair.second) {
            case (.right(let left), .right(let right)):
                self[keyPath: key] = .right(0)
                return .explode(left, right)
            default:
                fatalError("Invalid Snailfish Number: \(self)")
            }
        case .left(var pair):
            let result = pair.explode()
            self[keyPath: key] = .left(pair)
            return result
        case .right:
            return .none
        }
    }
    
    private mutating func split(_ key: WritableKeyPath<SnailfishNumber,Either<SnailfishNumber, Int>>) -> ReduceAction {
        switch self[keyPath: key] {
        case .right(let right) where right.shouldSplit:
            let left = Int(floor(Double(right)/2))
            let right = Int(ceil(Double(right)/2))
            self[keyPath: key] = .left(SnailfishNumber(depth: depth + 1, first: .right(left), second: .right(right)))
            return .split(right)
        case .left(var pair):
            let result = pair.split()
            self[keyPath: key] = .left(pair)
            return result
        case .right:
            return .none
        }
    }
    
    private mutating func explode() -> ReduceAction {
        switch explode(\.first) {
        case .explode(let left, let right):
            guard right > 0 else { return .explode(left, right) }
            switch second {
            case .left(var pair):
                if pair.add(left: right) {
                    second = .left(pair)
                    return .explode(left, 0)
                }
                return .explode(left, right)
            case .right(let number):
                second = .right(number + right)
                return .explode(left, 0)
            }
        case .split:
            fatalError("Unexpected result")
        case .none: break
        }
        switch explode(\.second) {
        case .explode(let left, let right):
            guard left > 0 else { return .explode(left, right) }
            switch first {
            case .left(var pair):
                if pair.add(right: left) {
                    first = .left(pair)
                    return .explode(0, right)
                }
                return .explode(left, right)
            case .right(let number):
                first = .right(number + left)
                return .explode(0, right)
            }
        case .split:
            fatalError("Unexpected result")
        case .none:
            break
        }
        return .none
    }
    
    private mutating func split() -> ReduceAction {
        switch split(\.first) {
        case .explode:
            fatalError("Unexpected result")
        case .split(let number):
            return .split(number)
        case .none: break
        }
        switch split(\.second) {
        case .explode:
            fatalError("Unexpected result")
        case .split(let number):
            return .split(number)
        case .none:
            break
        }
        return .none
    }
    
    mutating func step() -> ReduceAction {
        let explodeResult = explode()
        guard explodeResult == .none else {
            return explodeResult
        }
        let splitResult = split()
        guard splitResult == .none else {
            return splitResult
        }
        return .none
    }
    
    mutating func reduce() {
        while true {
            let result = step()
            if result == .none {
                break
            }
        }
    }
    
    var reduced: SnailfishNumber {
        var copy = self
        copy.reduce()
        return copy
    }
}

extension Array where Element == SnailfishNumber {
    var added: SnailfishNumber {
        var copy = self
        var first = copy.removeFirst()
        first = copy.reduce(into: first) { $0.add($1) }
        return first
    }
}

private func parse(input: String) throws -> [SnailfishNumber] {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .compactMap { SnailfishNumber(from: $0) }
}

struct Day18Puzzle1: Puzzle {
    private let numbers: [SnailfishNumber]

    init(contents: String) throws {
        numbers = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var all = numbers
        let first = all.removeFirst()
        let final = all.reduce(into: first) { $0.add($1) }
        return final.magnitude.description
    }
}

struct Day18Puzzle2: Puzzle {
    private let numbers: [SnailfishNumber]

    init(contents: String) throws {
        numbers = try parse(input: contents)
    }
    
    func answer() throws -> String {
        numbers
            .permutations(ofCount: 2)
            .map { $0.added.magnitude }
            .max()
            .unsafelyUnwrapped
            .description
    }
}
