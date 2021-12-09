//
//  Day8.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-08.
//

import Foundation

private enum Letter: String, CaseIterable {
    case a
    case b
    case c
    case d
    case e
    case f
    case g
}

private enum Segment: Int, CaseIterable {
    case top
    case topLeft
    case topRight
    case middle
    case bottomLeft
    case bottomRight
    case bottom
}

private let valueMapping: [Set<Segment>:Value] = [
    [.top, .topLeft, .topRight, .bottomLeft, .bottomRight, .bottom]: .zero,
    [.topRight, .bottomRight]: .one,
    [.top, .topRight, .middle, .bottomLeft, .bottom]: .two,
    [.top, .topRight, .middle, .bottomRight, .bottom]: .three,
    [.topLeft, .topRight, .middle, .bottomRight]: .four,
    [.top, .topLeft, .middle, .bottomRight, .bottom]: .five,
    [.top, .topLeft, .middle, .bottomLeft, .bottomRight, .bottom]: .six,
    [.top, .topRight, .bottomRight]: .seven,
    [.top, .topLeft, .topRight, .middle, .bottomLeft, .bottomRight, .bottom]: .eight,
    [.top, .topLeft, .topRight, .middle, .bottomRight, .bottom]: .nine
]

private enum Value: Int {
    case zero = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    
    init?(segments: [Segment]) {
        guard let value = valueMapping[Set(segments)] else {
            return nil
        }
        self = value
    }
}

private struct Pattern {
    var letters: [Letter]
}

private struct Note {
    var patterns: [Pattern]
    var values: [Pattern]
}

private func parse(input: String) throws -> [Note] {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .map { line in
            let parts = line.components(separatedBy: "|")
            let patterns: [Pattern] = parts[0]
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: .whitespaces)
                .map {
                    let letters = $0.compactMap { Letter(rawValue: String($0)) }
                    return Pattern(letters: letters)
                }
            let values: [Pattern] = parts[1]
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: .whitespaces)
                .map {
                    let letters = $0.compactMap { Letter(rawValue: String($0)) }
                    return Pattern(letters: letters)
                }
            return Note(patterns: patterns, values: values)
        }
}

struct Day8Puzzle1: Puzzle {
    private let notes: [Note]
    
    init(contents: String) throws {
        notes = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return notes
            .reduce(0) {
                $0 + $1.values
                    .filter { [2, 3, 4, 7].contains($0.letters.count) }
                    .count
            }
            .description
    }
}

struct Day8Puzzle2: Puzzle {
    private let notes: [Note]
    
    init(contents: String) throws {
        notes = try parse(input: contents)
    }
    
    private func findPatterns(in note: Note, of length: Int) -> [Pattern] {
        return note.patterns
            .filter { $0.letters.count == length }
    }
    
    private func findPattern(in note: Note, of length: Int) -> Set<Letter> {
        return note.patterns
            .first { $0.letters.count == length }
            .map { $0.letters }
            .map { Set($0) }
            .unsafelyUnwrapped
    }
    
    private func findTop(for note: Note) -> Letter {
        let one = findPattern(in: note, of: 2)
        let seven = findPattern(in: note, of: 3)
        let top = one.symmetricDifference(seven)
        assert(top.count == 1)
        return top.first!
    }
    
    private func findTopRightAndBottomRight(for note: Note) -> [Letter] {
        return Array(findPattern(in: note, of: 2))
    }
    
    private func findTopLeftAndMiddle(for note: Note) -> [Letter] {
        let one = findPattern(in: note, of: 2)
        let four = findPattern(in: note, of: 4)
        let both = one.symmetricDifference(four)
        assert(both.count == 2)
        return Array(both)
    }
    
    private func findMiddle(for note: Note) -> Letter {
        let topRightAndBottomRight = findTopRightAndBottomRight(for: note)
        let topLeftAndMiddle = findTopLeftAndMiddle(for: note)
        let zeroAndNine = findPatterns(in: note, of: 6)
            .filter { pattern in
                let letters = Set(pattern.letters)
                let both = letters.intersection(topRightAndBottomRight)
                return both.count == 2
            }
        assert(zeroAndNine.count == 2)
        
        let maybeZero = Set(zeroAndNine[0].letters)
        let maybeNine = Set(zeroAndNine[1].letters)
        let bottomLeftAndMiddle = maybeZero.symmetricDifference(maybeNine)
        let middle = bottomLeftAndMiddle.intersection(topLeftAndMiddle)
        assert(middle.count == 1)
        return middle.first!
    }
    
    private func findTopLeft(for note: Note, using middle: Letter) -> Letter {
        var topLeftAndMiddle = Set(findTopLeftAndMiddle(for: note))
        topLeftAndMiddle.remove(middle)
        assert(topLeftAndMiddle.count == 1)
        return topLeftAndMiddle.first!
    }
    
    private func findBottomTopRightAndBottomRight(for note: Note, using knowns: (top: Letter, topLeft: Letter, middle: Letter)) -> (bottom: Letter, topRight: Letter, bottomRight: Letter) {
        var five = findPatterns(in: note, of: 5)
            .filter { pattern in
                let letters = Set(pattern.letters)
                let joined = letters.intersection([knowns.top, knowns.topLeft, knowns.middle])
                return joined.count == 3
            }
            .first!
            .letters
            .set
        let four = findPattern(in: note, of: 4)
        five.remove(knowns.top)
        let bottomAndTopRight = five.symmetricDifference(four)
        assert(bottomAndTopRight.count == 2)
        
        let one = findPattern(in: note, of: 2)
        let bottomTopRightAndBottomRight = one.union(bottomAndTopRight)
        
        let bottom = one.symmetricDifference(bottomTopRightAndBottomRight)
        assert(bottom.count == 1)
        
        var bottomRight = one.symmetricDifference(bottomAndTopRight)
        bottomRight.remove(bottom.first!)
        assert(bottomRight.count == 1)
        
        var topRight = bottomTopRightAndBottomRight
        topRight.remove(bottom.first!)
        topRight.remove(bottomRight.first!)
        
        return (
            bottom: bottom.first!,
            topRight: topRight.first!,
            bottomRight: bottomRight.first!
        )
    }
    
    private func findBottomLeft(for note: Note, using letters: Set<Letter>) -> Letter {
        var eight = findPattern(in: note, of: 7)
        for letter in letters {
            eight.remove(letter)
        }
        assert(eight.count == 1)
        return eight.first!
    }
    
    func answer() throws -> String {
        var total = 0
        for note in notes {
            var mapping: [Letter:Segment] = [:]
            
            let top = findTop(for: note)
            mapping[top] = .top
            
            let middle = findMiddle(for: note)
            mapping[middle] = .middle
            
            let topLeft = findTopLeft(for: note, using: middle)
            mapping[topLeft] = .topLeft
            
            let (bottom, topRight, bottomRight) = findBottomTopRightAndBottomRight(for: note, using: (top: top, topLeft: topLeft, middle: middle))
            mapping[bottom] = .bottom
            mapping[topRight] = .topRight
            mapping[bottomRight] = .bottomRight
            
            let bottomLeft = findBottomLeft(for: note, using: [
                top,
                topLeft,
                topRight,
                middle,
                bottomRight,
                bottom
            ])
            mapping[bottomLeft] = .bottomLeft
            
            var result = ""
            for value in note.values {
                let segments = value.letters.map { mapping[$0]! }
                let value = Value(segments: segments)!
                result += value.rawValue.description
            }
            
            total += Int(result, radix: 10) ?? 0
        }
        return total.description
    }
}
