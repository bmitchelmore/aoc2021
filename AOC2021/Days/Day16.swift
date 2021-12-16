//
//  Day16.swift
//  AOC2021
//
//  Created by Blair Mitchelmore on 2021-12-16.
//

import Foundation

private enum BITSError: Error {
    case invalidPacketType
    case invalidPacketVersion
}

private struct Packet: CustomStringConvertible {
    var version: PacketVersion
    var type: PacketType
    var payload: PacketPayload
    
    var description: String {
        return [
            "v\(version.value)",
            "t\(type.rawValue)",
            payload.description
        ].joined(separator: " ")
    }
    
    init(_ bits: inout Bits) throws {
        let version: PacketVersion = try bits.take()
        let type: PacketType = try bits.take()
        switch type {
        case .literal:
            let value: Int = try bits.take()
            self.version = version
            self.type = type
            self.payload = .literal(value)
        case .sum, .product, .minumum, .maximum, .greaterThan, .lessThan, .equalTo:
            self.version = version
            self.type = type
            let lengthType: PacketLengthType = try bits.take()
            switch lengthType {
            case .bits:
                let length: Int = try bits.take(length: 15)
                var subset: Bits = bits.take(length: length)
                var packets: [Packet] = []
                while !subset.isEmpty {
                    try packets.append(Packet(&subset))
                }
                self.payload = .packets(packets)
            case .packets:
                let length: Int = try bits.take(length: 11)
                var packets: [Packet] = []
                for _ in 0..<length {
                    try packets.append(Packet(&bits))
                }
                self.payload = .packets(packets)
            }
        }
    }
    
    var reducer: (Int, Int) -> Int {
        switch type {
        case .sum:
            return { acc, val in acc + val }
        case .product:
            return { acc, val in acc * val }
        case .minumum:
            return { acc, val in min(acc, val) }
        case .maximum:
            return { acc, val in max(acc, val) }
        case .literal, .greaterThan, .lessThan, .equalTo:
            fatalError("Invalid Packet: \(self)")
        }
    }
    
    var identityValue: Int {
        switch type {
        case .sum:
            return 0
        case .product:
            return 1
        case .minumum:
            return .max
        case .maximum:
            return .min
        case .literal, .greaterThan, .lessThan, .equalTo:
            fatalError("Invalid Packet: \(self)")
        }
    }
    
    var comparator: (Int, Int) -> Int {
        switch type {
        case .sum, .product, .minumum, .maximum, .literal:
            fatalError("Invalid Packet: \(self)")
        case .greaterThan:
            return { a, b in a > b ? 1 : 0 }
        case .lessThan:
            return { a, b in a < b ? 1 : 0 }
        case .equalTo:
            return { a, b in a == b ? 1 : 0 }
        }
    }
    
    var value: Int {
        switch type {
        case .sum, .product, .minumum, .maximum:
            guard case .packets(let packets) = payload else {
                fatalError("Invalid Packet: \(self)")
            }
            return packets.map(\.value).reduce(identityValue, reducer)
        case .greaterThan, .lessThan, .equalTo:
            guard case .packets(let packets) = payload else {
                fatalError("Invalid Packet: \(self)")
            }
            assert(packets.count == 2)
            return comparator(packets[0].value, packets[1].value)
        case .literal:
            guard case .literal(let value) = payload else {
                fatalError("Invalid Packet: \(self)")
            }
            return value
        }
    }
}

private enum PacketLengthType {
    case bits
    case packets
    
    init(_ value: Bool) {
        switch value {
        case false: self = .bits
        case true: self = .packets
        }
    }
}

private enum PacketPayload: CustomStringConvertible {
    case literal(Int)
    case packets([Packet])
    
    var description: String {
        switch self {
        case .literal(let value):
            return "literal:\(value)"
        case .packets(let packets):
            return "[\(packets.map({$0.description}).joined(separator: ", "))]"
        }
    }
}

private struct PacketVersion {
    var value: UInt8
    
    init(_ value: UInt8) throws {
        guard value < 8 else {
            throw BITSError.invalidPacketVersion
        }
        self.value = value
    }
}

private enum PacketType: UInt8 {
    case sum
    case product
    case minumum
    case maximum
    case literal
    case greaterThan
    case lessThan
    case equalTo
    
    init(_ value: UInt8) throws {
        guard value < 8 else {
            throw BITSError.invalidPacketType
        }
        guard let value = PacketType(rawValue: value) else {
            throw BITSError.invalidPacketType
        }
        self = value
    }
}

private struct PacketNibble {
    var value: UInt8
    
    init(_ value: UInt8) {
        self.value = value
    }
}

private struct Bits: CustomStringConvertible {
    var bits: [Bool]
    
    var description: String {
        return bits
            .map { $0 ? "1" : "0" }
            .joined(separator: "")
    }
    
    var isEmpty: Bool {
        return bits.isEmpty
    }
    
    mutating func take(length: Int) -> Bits {
        let subset = Bits(bits: Array(bits.prefix(length)))
        bits.removeFirst(length)
        return subset
    }
    
    mutating func take() throws -> PacketLengthType {
        return PacketLengthType(bits.removeFirst())
    }
    
    mutating func take() throws -> PacketVersion {
        let size = 3
        var value: UInt8 = 0
        for bit in bits.prefix(size) {
            value |= bit ? 1 : 0
            value <<= 1
        }
        value >>= 1
        bits.removeFirst(size)
        return try PacketVersion(value)
    }
    
    mutating func take() throws -> PacketType {
        let size = 3
        var value: UInt8 = 0
        for bit in bits.prefix(size) {
            value |= bit ? 1 : 0
            value <<= 1
        }
        value >>= 1
        bits.removeFirst(size)
        return try PacketType(value)
    }
    
    mutating func take() -> PacketNibble {
        let size = 4
        var value: UInt8 = 0
        for bit in bits.prefix(size) {
            value |= bit ? 1 : 0
            value <<= 1
        }
        value >>= 1
        bits.removeFirst(size)
        return PacketNibble(value)
    }
    
    mutating func take() throws -> Int {
        var value = 0
        var more = true
        while more {
            if !bits.removeFirst() {
                more = false
            }
            let nibble: PacketNibble = take()
            value |= Int(nibble.value)
            if more {
                value <<= 4
            }
        }
        return value
    }
    
    mutating func take(length: Int) throws -> Int {
        var value = 0
        for i in 1...length {
            if bits.removeFirst() {
                value |= 1
            }
            if i != length {
                value <<= 1
            }
        }
        return value
    }
}

extension UInt8 {
    fileprivate var nibble: [Bool] {
        let size = 4
        var bits: [Bool] = []
        bits.reserveCapacity(size)
        var value = self
        for _ in 0..<size {
            bits.append(value & 1 == 1)
            value >>= 1
        }
        while bits.count < size {
            bits.append(false)
        }
        return bits.reversed()
    }
}

private func parse(input: String) throws -> Packet {
    let values = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .map { UInt8(String($0), radix: 16)! }
        .flatMap { $0.nibble }
    var bits = Bits(bits: values)
    let packet = try Packet(&bits)
    return packet
}

struct Day16Puzzle1: Puzzle {
    private let packet: Packet

    init(contents: String) throws {
        packet = try parse(input: contents)
    }
    
    private func sum(for packet: Packet) -> Int {
        var result = 0
        result += Int(packet.version.value)
        if case .packets(let packets) = packet.payload {
            for packet in packets {
                result += sum(for: packet)
            }
        }
        return result
    }
    
    func answer() throws -> String {
        return sum(for: packet).description
    }
}

struct Day16Puzzle2: Puzzle {
    private let packet: Packet

    init(contents: String) throws {
        packet = try parse(input: contents)
    }
    
    func answer() throws -> String {
        return packet.value.description
    }
}
