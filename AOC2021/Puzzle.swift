//
//  Puzzle.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-02.
//

import Foundation

protocol Puzzle {
    init(contents: String) throws
    func answer() -> String
}
