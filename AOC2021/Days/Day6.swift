//
//  Day6.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-06.
//

import Foundation

struct Lanternfish {
    var timer: Int
    
    init(_ timer: Int) {
        self.timer = timer
    }
}

extension Lanternfish {
    mutating func elapse() -> [Lanternfish] {
        if timer <= 0 {
            timer = 6
            return [
                Lanternfish(8)
            ]
        } else {
            timer -= 1
            return []
        }
    }
}

struct LanternfishPool {
    var fish: [Int:Int]
    
    init(_ fish: [Lanternfish]) {
        self.fish = [:]
        for fish in fish {
            add(fish: fish, count: 1)
        }
    }
    
    var count: Int {
        return fish.values.reduce(0, +)
    }
}

extension LanternfishPool {
    mutating func add(fish: Lanternfish, count: Int) {
        if let total = self.fish[fish.timer] {
            self.fish[fish.timer] = total + count
        } else {
            self.fish[fish.timer] = count
        }
    }
    mutating func elapse() {
        var next = LanternfishPool([])
        for (timer, count) in fish {
            var fish = Lanternfish(timer)
            let offspring = fish.elapse()
            next.add(fish: fish, count: count)
            for fish in offspring {
                next.add(fish: fish, count: count)
            }
        }
        self = next
    }
}

private func parse(input: String) throws -> LanternfishPool {
    let fish = input
        .components(separatedBy: ",")
        .compactMap { Int($0, radix: 10).map { Lanternfish($0) } }
    return LanternfishPool(fish)
}

struct Day6Puzzle1: Puzzle {
    private let pool: LanternfishPool
    
    init(contents: String) throws {
        pool = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var pool = self.pool
        for _ in 1...80 {
            pool.elapse()
        }
        return pool.count.description
    }
}

struct Day6Puzzle2: Puzzle {
    private let pool: LanternfishPool
    
    init(contents: String) throws {
        pool = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var pool = self.pool
        for _ in 1...256 {
            pool.elapse()
        }
        return pool.count.description
    }
}
