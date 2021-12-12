//
//  Day12.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-12.
//

import Foundation

private enum GraphValue: Equatable, Hashable {
    case start
    case end
    case big(id: String)
    case small(id: String)
    
    init?(_ str: String) {
        switch str {
        case "start": self = .start
        case "end": self = .end
        default:
            if str.allSatisfy(\.isUppercase) {
                self = .big(id: str)
            } else if str.allSatisfy(\.isLowercase) {
                self = .small(id: str)
            } else {
                return nil
            }
        }
    }
    
    var id: String {
        switch self {
        case .start:
            return "start"
        case .end:
            return "end"
        case .big(let id):
            return id
        case .small(let id):
            return id
        }
    }
}

private struct GraphPath: CustomStringConvertible {
    var values: [GraphValue]
    
    var description: String {
        return values.map(\.id).joined(separator: ",")
    }
}

private struct GraphVisitRecord {
    var node: GraphValue
    var visits: Int
    
    init(_ pair: (key: GraphValue, value: Int)) {
        self.node = pair.key
        self.visits = pair.value
    }
    
    var usedAugmentedSearch: Bool {
        switch node {
        case .start:
            return false
        case .end:
            return false
        case .big:
            return false
        case .small:
            return visits == 2
        }
    }
}

private enum GraphVisitationRules {
    case standard
    case augmented
    
    func canVisit(_ value: GraphValue, counts: [GraphValue:Int]) -> Bool {
        switch (value, counts[value] ?? 0) {
        case (_, 0): return true
        case (.start, _): return false
        case (.end, _): return false
        case (.big, _): return true
        case (.small, 1):
            switch self {
            case .standard:
                return false
            case .augmented:
                return counts
                    .map(GraphVisitRecord.init)
                    .filter(\.usedAugmentedSearch)
                    .isEmpty
            }
        case (.small, _): return false
        }
    }
}

private struct GraphPathState {
    var visited: [GraphValue:Int]
    var journey: [GraphValue]
    
    init(_ start: GraphValue) {
        visited = [start: 1]
        journey = [start]
    }
    
    mutating func visit(_ value: GraphValue) {
        if let existing = visited[value] {
            visited[value] = existing + 1
        } else {
            visited[value] = 1
        }
        journey.append(value)
    }
    
    func visiting(_ value: GraphValue) -> GraphPathState {
        var copy = self
        copy.visit(value)
        return copy
    }
    
    func canVisit(_ value: GraphValue, accordingTo rules: GraphVisitationRules) -> Bool {
        return rules.canVisit(value, counts: visited)
    }
    
    var path: GraphPath {
        return GraphPath(values: journey)
    }
}

private struct Graph {
    var map: [GraphValue:[GraphValue]]
    var rules: GraphVisitationRules = .standard
    
    func recurse(from src: GraphValue, to dest: GraphValue, state: GraphPathState) -> [GraphPath] {
        guard src != dest else { return [state.path] }
        guard let neighbours = map[src] else { return [] }
        return neighbours.reduce(into: []) { result, neighbour in
            guard state.canVisit(neighbour, accordingTo: rules) else { return }
            let paths = recurse(from: neighbour, to: dest, state: state.visiting(neighbour))
            result.append(contentsOf: paths)
        }
    }
    
    func paths(from src: GraphValue, to dest: GraphValue) -> [GraphPath] {
        recurse(from: src, to: dest, state: GraphPathState(src))
    }
}

private func parse(input: String) throws -> Graph {
    var map: [GraphValue:[GraphValue]] = [:]
    input.trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
        .forEach { line in
            let parts = line
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: "-")
            assert(parts.count == 2)
            guard
                let src = GraphValue(parts[0]),
                let dest = GraphValue(parts[1])
            else {
                return
            }
            if var existing = map[src] {
                existing.append(dest)
                map[src] = existing
            } else {
                map[src] = [dest]
            }
            if var existing = map[dest] {
                existing.append(src)
                map[dest] = existing
            } else {
                map[dest] = [src]
            }
        }
    return Graph(map: map)
}

struct Day12Puzzle1: Puzzle {
    private let graph: Graph
    
    init(contents: String) throws {
        graph = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var graph = self.graph
        graph.rules = .standard
        return graph
            .paths(from: .start, to: .end)
            .count
            .description
    }
}

struct Day12Puzzle2: Puzzle {
    private let graph: Graph
    
    init(contents: String) throws {
        graph = try parse(input: contents)
    }
    
    func answer() throws -> String {
        var graph = self.graph
        graph.rules = .augmented
        return graph
            .paths(from: .start, to: .end)
            .count
            .description
    }
}
