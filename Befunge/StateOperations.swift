import Foundation

extension State {
    func executePush(_ element: Int) {
        stack.append(element)
        currentStateChanges.append(.push(element))
    }

    func executePop() -> Int {
        let popped = stack.removeLast()
        currentStateChanges.append(.pop)
        return popped
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

}