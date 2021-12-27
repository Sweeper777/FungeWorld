import SpriteKit
import Befunge

class HUDScene: SKScene {
    private var textNode: SKLabelNode!
    
    func setup() {
        textNode = childNode(withName: "label") as! SKLabelNode
    }
    
    func updateWithState(_ state: State) {
        let stackString = state.stack.reversed().map(String.init).joined(separator: "\n")
        textNode.text = "Stack:\n\(stackString)"
    }
}
