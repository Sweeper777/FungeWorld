public struct Array2D<T: Codable>: Sequence, ExpressibleByArrayLiteral, Codable {

    public let columns: Int
    public let rows: Int
    fileprivate var array: [T]

    public init(columns: Int, rows: Int, initialValue: T) {
        self.columns = columns
        self.rows = rows
        array = .init(repeating: initialValue, count: rows*columns)
    }

    public subscript(column: Int, row: Int) -> T {
        get {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            return array[row*columns + column]
        }
        set {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            array[row*columns + column] = newValue
        }
    }

    public subscript(position: Position) -> T {
        get { self[position.x, position.y] }
        set { self[position.x, position.y] = newValue }
    }

    public subscript(safe position: Position) -> T? {
        get {
            if (0..<columns).contains(position.x) && (0..<rows).contains(position.y) {
                return self[position]
            }
            return nil
        }
    }

    public typealias Iterator = Array<T>.Iterator
    public typealias SubSequence = Array<T>.SubSequence
//    public typealias Element = [T]
    public func makeIterator() -> Iterator {
        array.makeIterator()
    }

    public var underestimatedCount: Int {
        array.underestimatedCount
    }

    public func map<T>(_ transform: (Iterator.Element) throws -> T) rethrows -> [T] {
        try array.map(transform)
    }
    public func filter(_ isIncluded: (Iterator.Element) throws -> Bool) rethrows -> [Iterator.Element] {
        try array.filter(isIncluded)
    }

    public func forEach(_ body: (Iterator.Element) throws -> Swift.Void) rethrows {
        try array.forEach(body)
    }
    public func dropFirst(_ n: Int) -> SubSequence {
        array.dropFirst(n)
    }
    public func dropLast(_ n: Int) -> SubSequence {
        array.dropLast(n)
    }

    public func drop(while predicate: (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
        try array.drop(while: predicate)
    }

    public func prefix(_ maxLength: Int) -> SubSequence {
        array.prefix(maxLength)
    }

    public func prefix(while predicate: (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
        try array.prefix(while: predicate)
    }

    public func suffix(_ maxLength: Int) -> SubSequence {
        array.suffix(maxLength)
    }


    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Iterator.Element) throws -> Bool) rethrows -> [SubSequence] {
        try array.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
    }

    public init(arrayLiteral elements: [T]...) {
        precondition(Set(elements.map { $0.count }).count == 1)
        columns = elements.first!.count
        rows = elements.count
        array = elements.flatMap { $0 }
    }

    public func indicesOf(itemsWhere predicate: (T) -> Bool) -> [Position] {
        var indices = [Position]()
        for x in 0..<columns {
            for y in 0..<rows {
                if predicate(self[x, y]) {
                    indices.append(Position(x, y))
                }
            }
        }
        return indices
    }

    public func firstIndex(where predicate: (T) -> Bool) -> Position? {
        for x in 0..<columns {
            for y in 0..<rows {
                if predicate(self[x, y]) {
                    return Position(x, y)
                }
            }
        }
        return nil
    }
}

public struct Position: Hashable, RawRepresentable, Codable {
    public init?(rawValue: Int) {
        x = rawValue / 1000
        y = rawValue % 1000
    }

    public var rawValue: Int {
        x * 1000 + y
    }

    public typealias RawValue = Int

    public let x: Int
    public let y: Int

    public static func ==(lhs: Position, rhs: Position) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }

    public func above() -> Position {
        Position(x, y - 1)
    }

    public func below() -> Position {
        Position(x, y + 1)
    }

    public func left() -> Position {
        Position(x - 1, y)
    }

    public func right() -> Position {
        Position(x + 1, y)
    }

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y))"
    }
}
