import Foundation

public protocol IOProtocol {
    func writeChar(_ char: UnicodeScalar)
    func writeInt(_ int: Int)
    func writeError(_ message: String)
    func readNumber() async throws -> Int
    func readChar() async throws -> UnicodeScalar
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
    case move(wrapped: Bool)
    case playfieldChange(x: Int, y: Int, newInstruction: UnicodeScalar)
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

    public var currentStateChanges: [StateChange] = []

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

    public func nextStep() async {
        currentStateChanges = []
        do {
            let currentInstruction = playfield[instructionPointer]
            if stringMode && currentInstruction != "\"" {
                executePush(Int(currentInstruction.value))
            } else {
                switch currentInstruction {
                case "0"..."9":
                    executePush(Int(currentInstruction.value - UnicodeScalar("0").value))
                case "+":
                    executeAdd()
                case "-":
                    executeSubtract()
                case "*":
                    executeMultiply()
                case "/":
                    try await executeDivide()
                case "%":
                    try await executeModulo()
                case "!":
                    executeNot()
                case "`":
                    executeGreaterThan()
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
                    executeHorizontalConditional()
                case "|":
                    executeVerticalConditional()
                case "\"":
                    executeToggleStringMode()
                case ":":
                    executeDup()
                case "\\":
                    executeSwap()
                case "$":
                    _ = executePop()
                case ".":
                    executeOutputInt()
                case ",":
                    executeOutputChar()
                case "#":
                    executeMove()
                case "p":
                    try executePut()
                case "g":
                    executeGet()
                case "&":
                    try await executeInputInt()
                case "~":
                    try await executeInputChar()
                case "@":
                    executeTerminate()
                    return
                case " ":
                    break
                default:
                    throw BefungeError.unknownOperation(currentInstruction)
                }
            }
            executeMove()
        } catch {
            handleError(error: error)
        }
    }

    func handleError(error: Error) {
        if let stateError = error as? BefungeError {
            switch stateError {
            case .unknownUnicodeScalar(let number):
                io.writeError("\(number) is not a valid Unicode Scalar!")
            case .unknownOperation(let c):
                io.writeError("'\(c)' is an unknown operation!")
            case .noCharInput:
                io.writeError("Please enter a character!")
            case .invalidNumberInput:
                io.writeError("Please enter a valid integer!")
            }
        } else {
            io.writeError("An unknown error occurred!")
        }
        executeTerminate()
    }
    
    public func toSourceCode() -> String {
        var sourceCode = ""
        for row in 0..<State.rows {
            for column in 0..<State.columns {
                sourceCode.append(String(playfield[column, row]))
            }
            sourceCode.append("\n")
        }
        return String(sourceCode.trailingSpacesTrimmed)
    }
}

extension StringProtocol {

    @inline(__always)
    var trailingSpacesTrimmed: Self.SubSequence {
        var view = self[...]

        while view.last?.isWhitespace == true {
            view = view.dropLast()
        }

        return view
    }
}
