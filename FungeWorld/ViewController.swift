import UIKit
import Befunge
import SceneKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var cameraOrientationToggleButton: UIButton!
    lazy var state = State(io: scene, code: "64+\"!dlroW ,olleH\">:#,_@")
    var hudShown = false
    @IBOutlet var hudView: UIView!

    var zoomGR: UIPinchGestureRecognizer!
    
    var stackController: BefungeStackViewController!

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
                yRange: 3...16,
                zRange: -1...Float(State.rows)
        )
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(didZoom))
        sceneView.addGestureRecognizer(zoomGR)

        updateHudToggleButtonTitle()
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

    @IBAction func hudToggleButtonDidTap() {
        hudShown.toggle()
        hudView.isHidden = !hudShown
        updateHudToggleButtonTitle()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.preciseLocation(in: sceneView)
        let prevLocation = touch.precisePreviousLocation(in: sceneView)
        let dx = location.x - prevLocation.x
        let dy = location.y - prevLocation.y
        scene.camera.move(dx: -Float(dx) / 50, dy: -Float(dy) / 50)
        sceneView.setNeedsDisplay()
        super.touchesMoved(touches, with: event)
    }

    func updateHudToggleButtonTitle() {
        if hudShown {
            cameraOrientationToggleButton.configuration?.title = "Hide HUD"
        } else {
            cameraOrientationToggleButton.configuration?.title = "Show HUD"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BefungeStackViewController {
            stackController = vc
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        stackController.displayStack([1, 2], animated: true)
    }
}
