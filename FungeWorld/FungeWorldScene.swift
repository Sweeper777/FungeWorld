import SceneKit
import Befunge

class FungeWorldScene : SCNScene, IOProtocol {

    var cameraNode: SCNNode!
    weak var state: State!

    func setup() {
        setupCamera()
        setupFloor()
        addLight(position: SCNVector3(-10, 10, -10))
        addLight(position: SCNVector3(-10, 10, 20))
        addLight(position: SCNVector3(20, 10, 20))
        addLight(position: SCNVector3(20, 10, -10))
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position.y = 10
        cameraNode.eulerAngles.x = -0.523599
        cameraNode.eulerAngles.y = -.pi / 2
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
    func writeChar(_ char: UnicodeScalar) {

    }

    func writeInt(_ int: Int) {

    }

    func writeError(_ message: String) {

    }

    func readNumber(completion: @escaping (Int) -> Void) {

    }

    func readChar(completion: @escaping (UnicodeScalar) -> Void) {

    }
}
