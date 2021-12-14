//
//  Day14.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-14.
//

import Foundation
import Algorithms

private struct Pair<A: Equatable & Hashable, B: Equatable & Hashable>: Equatable, Hashable, CustomStringConvertible {
    var a: A
    var b: B
    
    var description: String {
        return "(\(a), \(b))"
    }
}

private struct Template {
    var initialEnds: Pair<Character, Character>
    var pairs: [Pair<Character, Character>:Int]
    
    var counts: [Character:Int] {
        var counts: [Character:Int] = [:]
        if let existing = counts[initialEnds.a] {
            counts[initialEnds.a] = existing + 1
        } else {
            counts[initialEnds.a] = 1
        }
        if let existing = counts[initialEnds.b] {
            counts[initialEnds.b] = existing + 1
        } else {
            counts[initialEnds.b] = 1
        }
        for (pair, value) in pairs {
            if let existing = counts[pair.a] {
                counts[pair.a] = existing + value
            } else {
                counts[pair.a] = value
            }
            if let existing = counts[pair.b] {
                counts[pair.b] = existing + value
            } else {
                counts[pair.b] = value
            }
        }
        return counts.mapValues { $0 / 2 }
    }
    
    var score: Int {
        let pair = counts.minAndMax { a, b in
            a.value < b.value
        }
        return pair!.max.value - pair!.min.value
    }
    
    init(_ string: String) {
        initialEnds = Pair(a: string.first!, b: string.last!)
        pairs = string.adjacentPairs().reduce(into: [:], { counter, pair in
            let pair = Pair(a: pair.0, b: pair.1)
            if let existing = counter[pair] {
                counter[pair] = existing + 1
            } else {
                counter[pair] = 1
            }
        })
    }
    
    mutating func evaluate(_ rules: [Rule]) {
        var additions: [Pair<Pair<Character, Character>, Int>] = []
        var removals: [Pair<Pair<Character, Character>, Int>] = []
        for rule in rules {
            guard let value = pairs[rule.pair] else { continue }
            additions.append(Pair(a: rule.left, b: value))
            additions.append(Pair(a: rule.right, b: value))
            removals.append(Pair(a: rule.pair, b: value))
        }
        var replacement = pairs
        for addition in additions {
            if let existing = replacement[addition.a] {
                replacement[addition.a] = existing + addition.b
            } else {
                replacement[addition.a] = addition.b
            }
        }
        for removal in removals {
            if let existing = replacement[removal.a] {
                replacement[removal.a] = existing - removal.b
            } else {
                replacement[removal.a] = removal.b
            }
        }
        pairs = replacement
    }
    
    func evaluating(_ rules: [Rule]) -> Template {
        var copy = self
        copy.evaluate(rules)
        return copy
    }
}

private struct Rule {
    var pair: Pair<Character, Character>
    var result: Character
    
    var left: Pair<Character, Character> {
        return Pair(a: pair.a, b: result)
    }
    var right: Pair<Character, Character> {
        return Pair(a: result, b: pair.b)
    }
}

private func parse(input: String) throws -> (Template, [Rule]) {
    let parts = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n\n")
    assert(parts.count == 2)
    let template = Template(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
    let rules: [Rule] = parts[1]
        .components(separatedBy: .newlines)
        .map { line in
            let parts = line.components(separatedBy: " -> ")
            assert(parts.count == 2)
            assert(parts[0].count == 2)
            assert(parts[1].count == 1)
            return Rule(pair: Pair(a: parts[0].first!, b: parts[0].last!), result: parts[1].first!)
        }
    return (template, rules)
}

struct Day14Puzzle1: Puzzle {
    private let template: Template
    private let rules: [Rule]

    init(contents: String) throws {
        (template, rules) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return (1...10)
            .reduce(template) { template, _ in template.evaluating(rules) }
            .score
            .description
    }
}

struct Day14Puzzle2: Puzzle {
    private let template: Template
    private let rules: [Rule]

    init(contents: String) throws {
        (template, rules) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return (1...40)
            .reduce(template) { template, _ in template.evaluating(rules) }
            .score
            .description
    }
}
