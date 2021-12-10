//
//  Day4.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-04.
//

import Foundation

struct BingoBoard: CustomStringConvertible {
    var values: [[Int]]
    var matched: [[Bool]]
    
    init(_ input: String) {
        values = input
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map {
                $0
                    .components(separatedBy: " ")
                    .compactMap { Int($0, radix: 10)
                }
            }
        matched = values.map { [Bool](repeating: false, count: $0.count) }
    }
    
    mutating func call(_ number: Int) -> Int? {
        for (row, values) in values.enumerated() {
            for (column, value) in values.enumerated() {
                if value == number {
                    matched[row][column] = true
                }
            }
        }
        guard won else { return nil }
        return score * number
    }
    
    private var won: Bool {
        var won: Bool = false
        for row in 0..<values.count {
            let rowTrue = matched[row]
                .allSatisfy { $0 }
            if rowTrue {
                won = true
                break
            }
        }
        guard won == false else { return won }
        for col in 0..<values.count {
            let colTrue = matched
                .map { $0[col] }
                .allSatisfy { $0 }
            if colTrue {
                won = true
                break
            }
        }
        return won
    }
    
    private var score: Int {
        var score = 0
        for (row, values) in values.enumerated() {
            for (column, value) in values.enumerated() {
                if matched[row][column] == false {
                    score += value
                }
            }
        }
        return score
    }
    
    var description: String {
        var output = ""
        for (row, values) in values.enumerated() {
            for (col, value) in values.enumerated() {
                if matched[row][col] {
                    output += "*"
                } else {
                    output += " "
                }
                output += String(format: "%02d", value)
                if matched[row][col] {
                    output += "*"
                } else {
                    output += " "
                }
                output += " "
            }
            output += "\n"
        }
        return output
    }
}

private func parse(input: String) throws -> ([Int], [BingoBoard]) {
    var parts = input.components(separatedBy: "\n\n")
    let numbers = parts
        .removeFirst()
        .split(separator: ",")
        .compactMap { Int($0, radix: 10) }
    let boards = parts.map { BingoBoard($0) }
    return (numbers, boards)
}

struct Day4Puzzle1: Puzzle {
    private let numbers: [Int]
    private let boards: [BingoBoard]
    
    init(contents: String) throws {
        (numbers, boards) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var boards = self.boards
        for number in numbers {
            var score: Int? = nil
            boards = boards.map {
                var board = $0
                if let value = board.call(number) {
                    score = value
                }
                return board
            }
            if let score = score {
                return score.description
            }
        }
        throw AOCError.unknownAnswer
    }
}

struct Day4Puzzle2: Puzzle {
    private let numbers: [Int]
    private let boards: [BingoBoard]
    
    init(contents: String) throws {
        (numbers, boards) = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var boards = self.boards
        for number in numbers {
            for i in (0..<boards.count).reversed() {
                if let value = boards[i].call(number) {
                    if boards.count == 1 {
                        return value.description
                    } else {
                        boards.remove(at: i)
                    }
                }
            }
        }
        throw AOCError.unknownAnswer
    }
}
