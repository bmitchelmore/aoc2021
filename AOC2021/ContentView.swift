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

enum Puzzle {
    case Day1Puzzle1
    case Day1Puzzle2
    
    var section: String {
        switch self {
        case .Day1Puzzle1, .Day1Puzzle2:
            return "Day 1"
        }
    }
    
    var title: String {
        switch self {
        case .Day1Puzzle1:
            return "Puzzle 1"
        case .Day1Puzzle2:
            return "Puzzle 2"
        }
    }
    
    func solve(input: String) throws -> Int {
        switch self {
        case .Day1Puzzle1:
            let puzzle = try AOC2021.Day1Puzzle1(contents: input)
            let answer = puzzle.answer()
            return answer
        case .Day1Puzzle2:
            let puzzle = try AOC2021.Day1Puzzle2(contents: input)
            let answer = puzzle.answer()
            return answer
        }
    }
}

struct ContentView: View {
    @State var readingInput: Bool = false
    @State var inputString: String = ""
    @State var currentPuzzle: Puzzle?
    
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
    
    var items: [[Puzzle]] = [
        [.Day1Puzzle1, .Day1Puzzle2]
    ]
    
    var body: some View {
        List(items, id: \.self) { item in
            Section(item.first!.section) {
                ForEach(item, id: \.self) { item in
                    Text(item.title)
                        .sheet(isPresented: $readingInput) {
                            solve(inputString)
                        } content: {
                            PromptSheet(textValue: $inputString)
                        }
                        .onTapGesture {
                            currentPuzzle = item
                            readingInput = true
                        }
                }
            }
        }.listStyle(.sidebar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
