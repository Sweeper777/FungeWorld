import Foundation

public enum BefungeError: Error {
    case unknownUnicodeScalar(Int)
    case unknownOperation(UnicodeScalar)
    case noCharInput
    case invalidNumberInput
}

public extension State {
    func executePush(_ element: Int) {
        stack.append(element)
        currentStateChanges.append(.push(element))
    }

    func executePop() throws -> Int{
        if let popped = stack.popLast() {
            currentStateChanges.append(.pop)
            return popped
        } else {
            return 0
        }
    }

    func executeAdd() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(a &+ b)
    }

    func executeSubtract() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(b &- a)
    }

    func executeMultiply() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(a &* b)
    }

    func executeDivide() async throws -> Void {
        let a = try executePop()
        let b = try executePop()
        if a == 0 {
            await executeInputInt()
        } else {
            executePush(b / a)
        }
    }

    func executeModulo() async throws -> Void {
        let a = try executePop()
        let b = try executePop()
        if a == 0 {
            await executeInputInt()
        } else {
            executePush(b % a)
        }
    }

    func executeNot() throws {
        executePush(try executePop() == 0 ? 1 : 0)
    }

    func executeGreaterThan() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(b > a ? 1 : 0)
    }

    func executeChangeDirection(_ newDirection: Direction) {
        direction = newDirection
        currentStateChanges.append(.turn(to: newDirection))
    }

    func executeRandomDirection() {
        executeChangeDirection(Direction.allCases.randomElement()!)
    }

    func executeHorizontalConditional() throws {
        let value = try executePop()
        executeChangeDirection(value == 0 ? .right : .left)
    }

    func executeVerticalConditional() throws {
        let value = try executePop()
        executeChangeDirection(value == 0 ? .down : .up)
    }

    func executeToggleStringMode() {
        stringMode.toggle()
        currentStateChanges.append(.stringMode(stringMode))
    }

    func executeDup() throws {
        let value = try executePop()
        executePush(value)
        executePush(value)
    }

    func executeSwap() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(a)
        executePush(b)
    }

    func executeOutputChar() throws {
        io.writeChar(UnicodeScalar(try executePop()) ?? "?")
    }

    func executeOutputInt() throws {
        io.writeInt(try executePop())
    }

    func executeInputInt() async -> Void {
        executePush(await io.readNumber())
    }

    func executeInputChar() async -> Void {
        self.executePush(Int(await io.readChar().value))
    }

    func executeMove() throws {
        let translationFunction = direction.translationFunction
        instructionPointer = translationFunction(instructionPointer)
        instructionPointer = Position(
                instructionPointer.x %% State.columns,
                instructionPointer.y %% State.rows
                )
        currentStateChanges.append(.move)
    }

    func executeTerminate() {
        terminated = true
        currentStateChanges.append(.terminate)
    }

    func executeGet() throws {
        let y = try executePop()
        let x = try executePop()
        if (0..<State.rows).contains(y) && (0..<State.columns).contains(x) {
            executePush(Int(playfield[x, y].value))
        } else {
            executePush(0)
        }
    }

    func executePut() throws {
        let y = try executePop()
        let x = try executePop()
        let v = try executePop()
        if (0..<State.rows).contains(y) && (0..<State.columns).contains(x) {
            if let char = UnicodeScalar(v) {
                playfield[x, y] = char
            } else {
                throw BefungeError.unknownUnicodeScalar(v)
            }
        }
    }
}
