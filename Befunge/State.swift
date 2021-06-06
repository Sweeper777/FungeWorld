import Foundation

public protocol IOProtocol {
    func writeChar(_ char: UnicodeScalar)
    func writeInt(_ int: Int)
    func writeError(_ message: String)
    func readNumber(completion: @escaping (Int) -> Void)
    func readChar(completion: @escaping (UnicodeScalar) -> Void)
}

public enum Direction {
    case up, down, left, right
}

public class State {
    public var stack: [Int] = []
    public var playfield = Array2D<Character>(columns: 80, rows: 25, initialValue: " ")
    public var instructionPointer = Position(0, 0)
    public var direction = Direction.right
    public var io: IOProtocol

    public var stringMode = false
    public var terminated = false

    public init(io: IOProtocol) {
        self.io = io
    }
}