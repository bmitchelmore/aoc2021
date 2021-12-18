//
//  ContentView.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-01.
//

import SwiftUI

struct PromptSheet: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Binding var textValue: String
    
    var body: some View {
        TextEditor(text: _textValue)
            .frame(width: 400, height: 300, alignment: .center)
        Button("Submit") {
            dismiss()
        }
    }
}

enum Puzzles: String, CaseIterable {
    case Day1Puzzle1
    case Day1Puzzle2
    case Day2Puzzle1
    case Day2Puzzle2
    case Day3Puzzle1
    case Day3Puzzle2
    case Day4Puzzle1
    case Day4Puzzle2
    case Day5Puzzle1
    case Day5Puzzle2
    case Day6Puzzle1
    case Day6Puzzle2
    case Day7Puzzle1
    case Day7Puzzle2
    case Day8Puzzle1
    case Day8Puzzle2
    case Day9Puzzle1
    case Day9Puzzle2
    case Day10Puzzle1
    case Day10Puzzle2
    case Day11Puzzle1
    case Day11Puzzle2
    case Day12Puzzle1
    case Day12Puzzle2
    case Day13Puzzle1
    case Day13Puzzle2
    case Day14Puzzle1
    case Day14Puzzle2
    case Day15Puzzle1
    case Day15Puzzle2
    case Day16Puzzle1
    case Day16Puzzle2
    case Day17Puzzle1
    case Day17Puzzle2
    case Day18Puzzle1
    case Day18Puzzle2
    
    func puzzle(input: String) throws -> Puzzle {
        switch self {
        case .Day1Puzzle1:
            return try AOC2021.Day1Puzzle1(contents: input)
        case .Day1Puzzle2:
            return try AOC2021.Day1Puzzle2(contents: input)
        case .Day2Puzzle1:
            return try AOC2021.Day2Puzzle1(contents: input)
        case .Day2Puzzle2:
            return try AOC2021.Day2Puzzle2(contents: input)
        case .Day3Puzzle1:
            return try AOC2021.Day3Puzzle1(contents: input)
        case .Day3Puzzle2:
            return try AOC2021.Day3Puzzle2(contents: input)
        case .Day4Puzzle1:
            return try AOC2021.Day4Puzzle1(contents: input)
        case .Day4Puzzle2:
            return try AOC2021.Day4Puzzle2(contents: input)
        case .Day5Puzzle1:
            return try AOC2021.Day5Puzzle1(contents: input)
        case .Day5Puzzle2:
            return try AOC2021.Day5Puzzle2(contents: input)
        case .Day6Puzzle1:
            return try AOC2021.Day6Puzzle1(contents: input)
        case .Day6Puzzle2:
            return try AOC2021.Day6Puzzle2(contents: input)
        case .Day7Puzzle1:
            return try AOC2021.Day7Puzzle1(contents: input)
        case .Day7Puzzle2:
            return try AOC2021.Day7Puzzle2(contents: input)
        case .Day8Puzzle1:
            return try AOC2021.Day8Puzzle1(contents: input)
        case .Day8Puzzle2:
            return try AOC2021.Day8Puzzle2(contents: input)
        case .Day9Puzzle1:
            return try AOC2021.Day9Puzzle1(contents: input)
        case .Day9Puzzle2:
            return try AOC2021.Day9Puzzle2(contents: input)
        case .Day10Puzzle1:
            return try AOC2021.Day10Puzzle1(contents: input)
        case .Day10Puzzle2:
            return try AOC2021.Day10Puzzle2(contents: input)
        case .Day11Puzzle1:
            return try AOC2021.Day11Puzzle1(contents: input)
        case .Day11Puzzle2:
            return try AOC2021.Day11Puzzle2(contents: input)
        case .Day12Puzzle1:
            return try AOC2021.Day12Puzzle1(contents: input)
        case .Day12Puzzle2:
            return try AOC2021.Day12Puzzle2(contents: input)
        case .Day13Puzzle1:
            return try AOC2021.Day13Puzzle1(contents: input)
        case .Day13Puzzle2:
            return try AOC2021.Day13Puzzle2(contents: input)
        case .Day14Puzzle1:
            return try AOC2021.Day14Puzzle1(contents: input)
        case .Day14Puzzle2:
            return try AOC2021.Day14Puzzle2(contents: input)
        case .Day15Puzzle1:
            return try AOC2021.Day15Puzzle1(contents: input)
        case .Day15Puzzle2:
            return try AOC2021.Day15Puzzle2(contents: input)
        case .Day16Puzzle1:
            return try AOC2021.Day16Puzzle1(contents: input)
        case .Day16Puzzle2:
            return try AOC2021.Day16Puzzle2(contents: input)
        case .Day17Puzzle1:
            return try AOC2021.Day17Puzzle1(contents: input)
        case .Day17Puzzle2:
            return try AOC2021.Day17Puzzle2(contents: input)
        case .Day18Puzzle1:
            return try AOC2021.Day18Puzzle1(contents: input)
        case .Day18Puzzle2:
            return try AOC2021.Day18Puzzle2(contents: input)
        }
    }
    
    static var all: [[Puzzles]] {
        let dict = Dictionary(grouping: allCases) { $0.section }
        return dict
            .map { ($0.key, $0.value) }
            .sorted { $0.0.compare($1.0, options: .numeric, range: nil, locale: nil) == .orderedAscending }
            .map { $0.1 }
    }
    
    var section: String {
        guard let day = Int(rawValue.dropLast(1).dropFirst(3).trimmingCharacters(in: .decimalDigits.inverted), radix: 10) else { fatalError("Unknown Day: \(self)") }
        return "Day \(day)"
    }
    
    var title: String {
        switch rawValue.last {
        case "1":
            return "Puzzle 1"
        case "2":
            return "Puzzle 2"
        default:
            fatalError("Unknown Puzzle: \(self)")
        }
    }
    
    func solve(input: String) throws -> String {
        let puzzle = try puzzle(input: input)
        return try puzzle.answer()
    }
}

struct ContentView: View {
    @State var readingInput: Bool = false
    @State var inputString: String = ""
    @State var currentPuzzle: Puzzles?
    
    private func solve(_ input: String) {
        guard let puzzle = currentPuzzle else { return }
        do {
            let answer = try puzzle.solve(input: input)
            print("Answer: \(answer)")
        } catch {
            print("Error!")
            print(error)
        }
    }
    
    var body: some View {
        List(Puzzles.all, id: \.self) { item in
            Section(item.first!.section) {
                ForEach(item, id: \.self) { item in
                    Text(item.title)
                        .onTapGesture {
                            currentPuzzle = item
                            readingInput = true
                        }
                }
            }
        }
            .listStyle(.sidebar)
            .sheet(isPresented: $readingInput) {
                solve(inputString)
                inputString = ""
                currentPuzzle = nil
            } content: {
                PromptSheet(textValue: $inputString)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
