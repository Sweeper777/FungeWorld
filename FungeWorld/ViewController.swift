import UIKit
import Befunge
import SceneKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: SCNView!
    lazy var state = State(io: scene, code: "64+\"!dlroW ,olleH\">:#,_@")

    var zoomGR: UIPinchGestureRecognizer!

    var scene: FungeWorldScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = FungeWorldScene()
        scene.state = state
        scene.setup()
        sceneView.scene = scene
        sceneView.pointOfView = scene.cameraNode
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(didZoom))
        sceneView.addGestureRecognizer(zoomGR)
    }

    @objc func didZoom(_ gr: UIPinchGestureRecognizer) {
    }

    }
}