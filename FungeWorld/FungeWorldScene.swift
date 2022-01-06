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
                    rootNode.addChildNode(node)
                }
            }
        }
    }
    
    let instructionPointerNormalHeight = 1.f
    
    private func setupInstructionPointer() {
        instructionPointer = BefungeNodeGenerator.instructionPointerNode()
        rootNode.addChildNode(instructionPointer)
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
}
