import Foundation

public enum StateError: Error {
    case stackEmpty
    case movedOutOfBounds
    case unknownUnicodeScalar
    case unknownOperation
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
            throw StateError.stackEmpty
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

    func executeDivide() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(b / a)
    }

    func executeModulo() throws {
        let a = try executePop()
        let b = try executePop()
        executePush(b % a)
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

    func executeInputInt(completion: @escaping () -> Void) {
        io.readNumber(completion: { [weak self] in
            self?.executePush($0)
            completion()
        })
    }

    func executeInputChar(completion: @escaping () -> Void) {
        io.readChar(completion: { [weak self] in
            self?.executePush(Int($0.value))
            completion()
        })
    }

    func executeMove() throws {
        let translationFunction = direction.translationFunction
        instructionPointer = translationFunction(instructionPointer)
        if !(0..<State.columns).contains(instructionPointer.x) ||
                !(0..<State.rows).contains(instructionPointer.y) {
            throw StateError.movedOutOfBounds
        }
        currentStateChanges.append(.move)
    }

    func executeTerminate() {
        terminated = true
        currentStateChanges.append(.terminate)
    }

    func executeGet() throws {
        let x = try executePop()
        let y = try executePop()
        executePush(Int(playfield[x, y].value))
    }

    func executePut() throws {
        let x = try executePop()
        let y = try executePop()
        let v = try executePop()
        if let char = UnicodeScalar(v) {
            playfield[x, y] = char
        } else {
            throw StateError.unknownUnicodeScalar
        }
    }
}