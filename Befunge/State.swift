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

    var translationFunction: (Position) -> Position {
        switch self {
        case .up:
            return { $0.above() }
        case .down:
            return { $0.below() }
        case .left:
            return { $0.left() }
        case .right:
            return { $0.right() }
        }
    }
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

    public init(io: IOProtocol, code: String) {
        self.io = io

        var row = 0
        var column = 0
        for unicodeScalar in code.unicodeScalars {
            if unicodeScalar == "\n" {
                column = 0
                row += 1
                continue
            }
            if row < State.rows && column < State.columns {
                playfield[column, row] = unicodeScalar
            }
            column += 1
        }
    }

    public func nextStep(completion: @escaping () -> Void) {
        do {
            let currentInstruction = playfield[instructionPointer]
            if stringMode {
                executePush(Int(currentInstruction.value))
            } else {
                switch currentInstruction {
                case "0"..."9":
                    executePush(Int(currentInstruction.value - UnicodeScalar("0").value))
                case "+":
                    try executeAdd()
                case "-":
                    try executeSubtract()
                case "*":
                    try executeMultiply()
                case "/":
                    try executeDivide()
                case "%":
                    try executeModulo()
                case "!":
                    try executeNot()
                case "`":
                    try executeGreaterThan()
                case ">":
                    executeChangeDirection(.right)
                case "<":
                    executeChangeDirection(.left)
                case "v":
                    executeChangeDirection(.down)
                case "^":
                    executeChangeDirection(.up)
                case "?":
                    executeRandomDirection()
                case "_":
                    try executeHorizontalConditional()
                case "|":
                    try executeVerticalConditional()
                case "\"":
                    executeToggleStringMode()
                case ":":
                    try executeDup()
                case "\\":
                    try executeSwap()
                case "$":
                    _ = try executePop()
                case ".":
                    try executeOutputInt()
                case ",":
                    try executeOutputChar()
                case "#":
                    try executeMove()
                case "p":
                    try executePut()
                case "g":
                    try executeGet()
                case "&":
                    executeInputInt(completion: { [weak self] in
                        self?.postExecute()
                        completion()
                    })
                    return
                case "~":
                    executeInputChar(completion: { [weak self] in
                        self?.postExecute()
                        completion()
                    })
                    return
                case "@":
                    executeTerminate()
                    return
                case " ":
                    break
                default:
                    throw StateError.unknownOperation
                }
            }
            postExecute()
            completion()
        } catch {
            handleError(error: error)
            completion()
        }
    }

    func postExecute() {
        do {
            try executeMove()
        } catch {
            handleError(error: error)
        }
    }

    func handleError(error: Error) {
        if let stateError = error as? StateError {
            switch stateError {
            case .stackEmpty:
                io.writeError("The stack is empty!")
            case .movedOutOfBounds:
                io.writeError("That is the edge of the playfield!")
            case .unknownUnicodeScalar:
                io.writeError("That is not a valid Unicode Scalar!")
            case .unknownOperation:
                io.writeError("That is an unknown operation!")
            }
        } else {
            io.writeError("An unknown error occurred!")
        }
        executeTerminate()
    }
}

public func printPlayfield(_ playfield: Array2D<UnicodeScalar>) {
    for row in (0..<playfield.rows) {
        for col in (0..<playfield.columns) {
            print(playfield[col, row], terminator: "")
        }
        print()
    }
}