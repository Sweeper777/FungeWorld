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
        scene.camera = FungeWorldCamera(
                cameraNode: sceneView.pointOfView!,
                xRange: -1...Float(State.columns),
                yRange: 5...16,
                zRange: -1...Float(State.rows)
        )
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(didZoom))
        sceneView.addGestureRecognizer(zoomGR)
    }

    var prevZoom: CGFloat = 0
    @objc func didZoom(_ gr: UIPinchGestureRecognizer) {
        if gr.state == .changed {
            scene.camera.zoom = prevZoom / gr.scale
            sceneView.setNeedsDisplay()
        } else if gr.state == .began {
            prevZoom = scene.camera.zoom
        }
    }

    }
}