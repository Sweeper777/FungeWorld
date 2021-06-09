import Foundation

public protocol IOProtocol {
    func writeChar(_ char: UnicodeScalar)
    func writeInt(_ int: Int)
    func writeError(_ message: String)
    func readNumber(completion: @escaping (Int) -> Void)
    func readChar(completion: @escaping (UnicodeScalar) -> Void)
}

public enum Direction : CaseIterable {
    case up, down, left, right
}

public enum StateChange {
    case push(Int)
    case pop
    case turn(to: Direction)
    case stringMode(Bool)
    case move
    case terminate
}

public final class State {
    public var stack: [Int] = []
    public static let columns = 80
    public static let rows = 25
    public var playfield = Array2D<UnicodeScalar>(columns: columns, rows: rows, initialValue: " ")
    public var instructionPointer = Position(0, 0)
    public var direction = Direction.right
    public var io: IOProtocol

    public var stringMode = false
    public var terminated = false

    var currentStateChanges: [StateChange] = []

    public init(io: IOProtocol) {
        self.io = io
    }
}