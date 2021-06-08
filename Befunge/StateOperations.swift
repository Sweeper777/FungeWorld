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
}