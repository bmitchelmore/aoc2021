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

enum Puzzles {
    case Day1Puzzle1
    case Day1Puzzle2
    case Day2Puzzle1
    case Day2Puzzle2
    
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
        }
    }
    
    var section: String {
        switch self {
        case .Day1Puzzle1, .Day1Puzzle2:
            return "Day 1"
        case .Day2Puzzle1, .Day2Puzzle2:
            return "Day 2"
        }
    }
    
    var title: String {
        switch self {
        case .Day1Puzzle1, .Day2Puzzle1:
            return "Puzzle 1"
        case .Day1Puzzle2, .Day2Puzzle2:
            return "Puzzle 2"
        }
    }
    
    func solve(input: String) throws -> String {
        let puzzle = try puzzle(input: input)
        return puzzle.answer()
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
    
    var items: [[Puzzles]] = [
        [.Day1Puzzle1, .Day1Puzzle2],
        [.Day2Puzzle1, .Day2Puzzle2]
    ]
    
    var body: some View {
        List(items, id: \.self) { item in
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
