import UIKit
import Befunge
import SceneKit
import SCLAlertView

class ViewController: UIViewController, IOProtocol {
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var cameraOrientationToggleButton: UIButton!
    lazy var state = State(io: self, code: "64+\"!dlroW ,olleH\">:#,_@")
    var hudShown = false
    @IBOutlet var hudView: UIView!
    @IBOutlet var stringModeLabel: UILabel!
    @IBOutlet var outputLabel: UITextView!

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
        _ = Task { [weak self] in
            guard let `self` = self else { return }
            var currentDirection = self.state.direction
            await self.state.nextStep()
            for stateChange in self.state.currentStateChanges {
                switch stateChange {
                case .push(let number):
                    await self.stackController.animatePush(number)
                    await Task.sleep(200_000_000)
                case .pop:
                    await self.stackController.animatePop()
                    await Task.sleep(200_000_000)
                case .turn(to: let direction):
                    await self.scene.instructionPointer.runAction(
                        SCNAction.rotateTo(x: .pi / 2,
                                           y: CGFloat(self.scene.eulerY(forDirection: direction)),
                                           z: 0,
                                           duration: 0.2)
                    )
                    currentDirection = direction
                case .stringMode(let stringModeOn):
                    self.stringModeLabel.isHidden = !stringModeOn
                case .move:
                    await self.scene.instructionPointer.runAction(
                        SCNAction.move(by: self.scene.unitVector(forDirection: currentDirection), duration: 0.2)
                    )
                case .terminate:
                    print("TODO: Terminate")
                }
            }
        }
    }
    
    func writeChar(_ char: UnicodeScalar) {

    }

    func writeInt(_ int: Int) {

    }

    func writeError(_ message: String) {
        SCLAlertView().showError("Error", subTitle: message, closeButtonTitle: "OK")
    }

    var inputCharBuffer = [UnicodeScalar]()
    
    func readNumber() async throws -> Int {
        let input = await readInput(withPrompt: "Enter a number:")
        if let number = Int(input) {
            return number
        } else {
            throw BefungeError.invalidNumberInput
        }
    }
    
    func readChar() async throws -> UnicodeScalar {
        if inputCharBuffer.isEmpty {
            inputCharBuffer = await readInput(withPrompt: "Enter a character (extra characters will be buffered):").unicodeScalars.reversed()
        }
        if inputCharBuffer.isEmpty {
            throw BefungeError.noCharInput
        }
        return inputCharBuffer.removeLast()
    }
    
    func readInput(withPrompt prompt: String) async -> String {
        return await withCheckedContinuation({ continuation in
            let alert = SCLAlertView(appearance: .init(showCloseButton: false))
            let textField = alert.addTextField("Input")
            alert.addButton("OK") {
                continuation.resume(returning: textField.text ?? "")
            }
            alert.showEdit("Input", subTitle: prompt)
        })
    }
}
