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

    func executePop() -> Int{
        if let popped = stack.popLast() {
            currentStateChanges.append(.pop)
            return popped
        } else {
            return 0
        }
    }

    func executeAdd() {
        let a = executePop()
        let b = executePop()
        executePush(a &+ b)
    }

    func executeSubtract() {
        let a = executePop()
        let b = executePop()
        executePush(b &- a)
    }

    func executeMultiply() {
        let a = executePop()
        let b = executePop()
        executePush(a &* b)
    }

    func executeDivide() async throws {
        let a = executePop()
        let b = executePop()
        if a == 0 {
            try await executeInputInt()
        } else {
            executePush(b / a)
        }
    }

    func executeModulo() async throws {
        let a = executePop()
        let b = executePop()
        if a == 0 {
            try await executeInputInt()
        } else {
            executePush(b % a)
        }
    }

    func executeNot() {
        executePush(executePop() == 0 ? 1 : 0)
    }

    func executeGreaterThan() {
        let a = executePop()
        let b = executePop()
        executePush(b > a ? 1 : 0)
    }

    func executeChangeDirection(_ newDirection: Direction) {
        direction = newDirection
        currentStateChanges.append(.turn(to: newDirection))
    }

    func executeRandomDirection() {
        executeChangeDirection(Direction.allCases.randomElement()!)
    }

    func executeHorizontalConditional() {
        let value = executePop()
        executeChangeDirection(value == 0 ? .right : .left)
    }

    func executeVerticalConditional() {
        let value = executePop()
        executeChangeDirection(value == 0 ? .down : .up)
    }

    func executeToggleStringMode() {
        stringMode.toggle()
        currentStateChanges.append(.stringMode(stringMode))
    }

    func executeDup() {
        let value = executePop()
        executePush(value)
        executePush(value)
    }

    func executeSwap() {
        let a = executePop()
        let b = executePop()
        executePush(a)
        executePush(b)
    }

    func executeOutputChar() {
        io.writeChar(UnicodeScalar(executePop()) ?? "?")
    }

    func executeOutputInt() {
        io.writeInt(executePop())
    }

    func executeInputInt() async throws {
        executePush(try await io.readNumber())
    }

    func executeInputChar() async throws {
        self.executePush(Int(try await io.readChar().value))
    }

    func executeMove() {
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

    func executeGet() {
        let y = executePop()
        let x = executePop()
        if (0..<State.rows).contains(y) && (0..<State.columns).contains(x) {
            executePush(Int(playfield[x, y].value))
        } else {
            executePush(0)
        }
    }

    func executePut() throws {
        let y = executePop()
        let x = executePop()
        let v = executePop()
        if (0..<State.rows).contains(y) && (0..<State.columns).contains(x) {
            if let char = UnicodeScalar(v) {
                playfield[x, y] = char
                currentStateChanges.append(.playfieldChange(x: x, y: y, newInstruction: char))
            } else {
                throw BefungeError.unknownUnicodeScalar(v)
            }
        }
    }
}
