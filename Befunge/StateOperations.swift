import Foundation

enum StateError: Error {
    case stackEmpty
}

extension State {
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

    func executeDivide() {
        let a = executePop()
        let b = executePop()
        executePush(b / a)
    }

    func executeModulo() {
        let a = executePop()
        let b = executePop()
        executePush(b % a)
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
}