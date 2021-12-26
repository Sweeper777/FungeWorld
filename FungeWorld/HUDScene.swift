import SpriteKit
import Befunge

class HUDScene: SKScene {
    private var textNode: SKLabelNode!
    
    func setup() {
        textNode = SKLabelNode(text: "Stack:")
        textNode.fontSize = 30
        textNode.fontColor = .black
        self.addChild(textNode)
    }
    
    func updateWithState(_ state: State) {
        let stackString = state.stack.reversed().map(String.init).joined(separator: "\n")
        textNode.text = "Stack:\n\(stackString)"
    }
}
