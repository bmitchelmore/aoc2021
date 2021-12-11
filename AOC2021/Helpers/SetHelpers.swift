//
//  SetHelpers.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-11.
//

import Foundation

extension Collection where Element: Hashable {
    var set: Set<Element> {
        return Set(self)
    }
}
