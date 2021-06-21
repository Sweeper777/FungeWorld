import UIKit
import Befunge
import SceneKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: SCNView!
    lazy var state = State(io: scene, code: "64+\"!dlroW ,olleH\">:#,_@")

    var scene: FungeWorldScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = FungeWorldScene()
        scene.state = state
        scene.setup()
        sceneView.scene = scene
        sceneView.pointOfView = scene.cameraNode
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .pan
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        sceneView.pointOfView!.eulerAngles.x = 0
        sceneView.pointOfView?.position.x = 0
        sceneView.pointOfView?.position.z = 0
        SCNTransaction.commit()
        SCNTransaction.animationDuration = 0
    }
}