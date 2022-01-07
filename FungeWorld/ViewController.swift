import UIKit
import Befunge
import SceneKit
import SCLAlertView

class ViewController: UIViewController, IOProtocol {
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var cameraOrientationToggleButton: UIButton!
    
    let code = "2>:3g\" \"-!v\\  g30          <\n |!`\"O\":+1_:.:03p>03g+:\"O\"`|\n @               ^  p3\\\" \":<\n2 234567890123456789012345678901234567890123456789012345678901234567890123456789"
    
    lazy var state = State(io: self, code: code)
    var hudShown = false
    @IBOutlet var hudView: UIView!
    @IBOutlet var stringModeLabel: UILabel!
    @IBOutlet var outputLabel: UITextView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var stepButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var buttonsStackView: UIStackView!

    var zoomGR: UIPinchGestureRecognizer!
    var stackController: BefungeStackViewController!
    var animationTask: Task<Void, Never>?
    var isPaused = false {
        didSet {
            stepButton.isEnabled = isPaused
        }
    }

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
        updateOutputDisplay()
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
    
    
    func makeOneStepAnimationTask() -> Task<Void, Never> {
        Task { [weak self] in
            guard let `self` = self else { return }
            var currentDirection = self.state.direction
            await self.state.nextStep()
            for stateChange in self.state.currentStateChanges {
                switch stateChange {
                case .push(let number):
                    if hudShown {
                        await self.stackController.animatePush(number)
                        await Task.sleep(UInt64(FungeWorldScene.animationDuration * 1_000_000_000))
                    }
                case .pop:
                    if hudShown {
                        await self.stackController.animatePop()
                        await Task.sleep(UInt64(FungeWorldScene.animationDuration * 1_000_000_000))
                    }
                case .turn(to: let direction):
                    await self.scene.instructionPointer.runAction(
                        SCNAction.rotateTo(x: .pi / 2,
                                           y: CGFloat(self.scene.eulerY(forDirection: direction)),
                                           z: 0,
                                           duration: FungeWorldScene.animationDuration,
                                           usesShortestUnitArc: true)
                    )
                    currentDirection = direction
                case .stringMode(let stringModeOn):
                    self.stringModeLabel.isHidden = !stringModeOn
                case .move:
                    await self.scene.instructionPointer.runAction(
                        SCNAction.move(by: self.scene.unitVector(forDirection: currentDirection), duration: FungeWorldScene.animationDuration)
                    )
                case .terminate:
                    print("TODO: Terminate")
                }
            }
        }
        
    }
    
    func makeAnimationTask() -> Task<Void, Never> {
        Task { [weak self] in
            guard let `self` = self else { return }
            while !Task.isCancelled {
                await self.makeOneStepAnimationTask().value
            }
        }
    }
    
    @IBAction func playPauseButtonDidTap() {
        guard (animationTask == nil) == isPaused else { return }
        
        if let task = animationTask { // should pause
            playPauseButton.configuration?.image = UIImage(systemName: "play.fill")
            task.cancel()
            animationTask = nil
            isPaused = true
        } else { // should play
            isPaused = false
            playPauseButton.configuration?.image = UIImage(systemName: "pause.fill")
            animationTask = makeAnimationTask()
        }
    }

    @IBAction func hudToggleButtonDidTap() {
        guard (animationTask == nil) == isPaused else { return }
        
        Task { [weak self] in
            guard let `self` = self else { return }
            self.hudShown.toggle()
            self.hudView.isHidden = !self.hudShown
            if let animationTask = self.animationTask {
                animationTask.cancel()
            }
            self.updateHudToggleButtonTitle()
            await self.stackController.animateStack(state.stack)
            if self.animationTask != nil {
                self.animationTask = self.makeAnimationTask()
            }
        }
    }
    
    @IBAction func stepButtonDidTap() {
        }
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
    
    func updateOutputDisplay(withString string: String = "") {
        var attributedString = AttributedString(string)
        attributedString.backgroundColor = .black
        attributedString.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
        attributedString.foregroundColor = .green
        outputLabel.attributedText = NSAttributedString(attributedString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BefungeStackViewController {
            stackController = vc
        }
    }
    var outputBuffer = [UnicodeScalar]()
    
    func writeChar(_ char: UnicodeScalar) {
        outputBuffer.append(char)
        updateOutputDisplay(withString: String(String.UnicodeScalarView(outputBuffer)))
    }

    func writeInt(_ int: Int) {
        outputBuffer.append(contentsOf: "\(int) ".unicodeScalars)
        updateOutputDisplay(withString: String(String.UnicodeScalarView(outputBuffer)))
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
