import UIKit
import Befunge
import SceneKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: SCNView!

    var scene: FungeWorldScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = FungeWorldScene()
        scene.setup()
        sceneView.scene = scene
        sceneView.pointOfView = scene.cameraNode
        sceneView.allowsCameraControl = true
    }
}

