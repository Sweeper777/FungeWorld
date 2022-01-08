import SceneKit
import Befunge

class FungeWorldScene : SCNScene {

    static let animationDuration = 0.1
    var cameraNode: SCNNode!
    var instructionPointer: SCNNode!
    weak var state: State!

    var camera: FungeWorldCamera!

    func setup() {
        setupCamera()
        setupFloor()
        setupInstructions()
        setupInstructionPointer()
        addLight(position: SCNVector3(0, 10, State.rows))
        addLight(position: SCNVector3(State.columns, 10, 0))
        addLight(position: SCNVector3(State.columns, 10, State.rows))
        addLight(position: SCNVector3(0, 10, 0))
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position.y = 10
        cameraNode.eulerAngles.x = -1
        cameraNode.position.x = 1
        cameraNode.position.z = 1
    }

    func addLight(position: SCNVector3) {
        let lightNode = SCNNode()
        lightNode.position = position
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        rootNode.addChildNode(lightNode)
    }

    private func setupFloor() {
        let floorGeometry = SCNFloor()
        floorGeometry.firstMaterial = SCNMaterial()
        floorGeometry.firstMaterial?.diffuse.contents = UIImage(named: "grass")
        floorGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(32, 32, 0)
        floorGeometry.firstMaterial?.diffuse.wrapS = .repeat
        floorGeometry.firstMaterial?.diffuse.wrapT = .repeat
        let floor = SCNNode(geometry: floorGeometry)
        rootNode.addChildNode(floor)

        let squareGeometry = SCNPlane(width: 0.9, height: 0.9)
        squareGeometry.cornerRadius = 0.1
        squareGeometry.firstMaterial?.diffuse.contents = UIColor.white
        for x in 0..<State.columns {
            for y in 0..<State.rows {
                let node = SCNNode(geometry: squareGeometry)
                node.position = SCNVector3(x.f, 0.001, y.f)
                node.eulerAngles.x = -.pi / 2
                rootNode.addChildNode(node)
            }
        }
    }

    private func setupInstructions() {
        for x in 0..<State.columns {
            for y in 0..<State.rows {
                if state.playfield[x, y] != " " {
                    let node = BefungeNodeGenerator.node(for: "\(state.playfield[x, y])")
                    node.position = SCNVector3(x.f, 0.001, y.f)
                    node.name = "instruction \(x),\(y)"
                    rootNode.addChildNode(node)
                }
            }
        }
    }
    
    let instructionPointerNormalHeight = 1.f
    
    private func setupInstructionPointer() {
        instructionPointer = BefungeNodeGenerator.instructionPointerNode()
        rootNode.addChildNode(instructionPointer)
        instructionPointer.opacity = 0.5
        synchroniseInstructionPointerWithState()
    }
    
    func synchroniseInstructionPointerWithState() {
        instructionPointer.position = SCNVector3(state.instructionPointer.x.f,
                                                 instructionPointerNormalHeight,
                                                 state.instructionPointer.y.f)
        instructionPointer.eulerAngles.y = eulerY(forDirection: state.direction)
    }
    
    func eulerY(forDirection direction: Direction) -> Float {
        switch direction {
        case .up:
            return 0
        case .down:
            return .pi
        case .left:
            return 3 * .pi / 2
        case .right:
            return .pi / 2
        }
    }
    
    func rotateInstructionPointer(to direction: Direction) async {
        await instructionPointer.runAction(
            SCNAction.rotateTo(x: .pi / 2,
                               y: CGFloat(eulerY(forDirection: direction)),
                               z: 0,
                               duration: FungeWorldScene.animationDuration,
                               usesShortestUnitArc: true)
        )
    }
    
    func moveInstructionPointer(towards direction: Direction) async {
        await instructionPointer.runAction(
            SCNAction.move(by: unitVector(forDirection: direction), duration: FungeWorldScene.animationDuration)
        )
    }
    
    func unitVector(forDirection direction: Direction) -> SCNVector3 {
        switch direction {
        case .up:
            return SCNVector3(x: 0, y: 0, z: -1)
        case .down:
            return SCNVector3(x: 0, y: 0, z: 1)
        case .left:
            return SCNVector3(x: -1, y: 0, z: 0)
        case .right:
            return SCNVector3(x: 1, y: 0, z: 0)
        }
    }
    
    func animatePlayfieldChange(x: Int, y: Int, newInstruction: UnicodeScalar) async {
        guard state.playfield[x, y] != newInstruction else { return }
        let originalNode = rootNode.childNode(withName: "instruction \(x),\(y)", recursively: false)
        let hideAction = SCNAction.sequence([.fadeOut(duration: FungeWorldScene.animationDuration), .removeFromParentNode()])
        let appearAction = SCNAction.fadeIn(duration: FungeWorldScene.animationDuration)
        switch (originalNode, newInstruction) {
        case (let node?, " "):
            await node.runAction(hideAction)
        case (nil, let instr) where instr != " ":
            let node = BefungeNodeGenerator.node(for: "\(state.playfield[x, y])")
            node.position = SCNVector3(x.f, 0.001, y.f)
            node.name = "instruction \(x),\(y)"
            node.opacity = 0
            rootNode.addChildNode(node)
            await node.runAction(appearAction)
        case (let node?, let instr) where instr != " ":
            let newNode = BefungeNodeGenerator.node(for: "\(state.playfield[x, y])")
            newNode.position = SCNVector3(x.f, 0.001, y.f)
            newNode.name = "instruction \(x),\(y)"
            newNode.opacity = 0
            rootNode.addChildNode(newNode)
            await node.runAction(hideAction)
            await newNode.runAction(appearAction)
        default:
            break
        }
    }
}
