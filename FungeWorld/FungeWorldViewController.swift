import UIKit
import Befunge
import SceneKit
import SCLAlertView

class FungeWorldViewController: UIViewController, IOProtocol {
    
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var cameraOrientationToggleButton: UIButton!
    
    lazy var state = State(io: self, code: "")
    var hudShown = false
    @IBOutlet var hudView: UIView!
    @IBOutlet var stringModeLabel: UILabel!
    @IBOutlet var terminatedLabel: UILabel!
    @IBOutlet var outputLabel: UITextView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var stepButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var buttonsStackView: UIStackView!

    var zoomGR: UIPinchGestureRecognizer!
    var stackController: BefungeStackViewController!
    var animationTask: Task<Void, Never>?
    var isPaused = true {
        didSet {
            stepButton.isEnabled = isPaused
        }
    }
    var isTerminated = false
    var code = ""

    var scene: FungeWorldScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
        
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(didZoom))
        sceneView.addGestureRecognizer(zoomGR)
        updateHudToggleButtonTitle()
        updateOutputDisplay()
        setupMenu()
        buttonsStackView.layer.cornerRadius = buttonsStackView.height / 2
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
    
    func setupMenu() {
        menuButton.menu = UIMenu(children: [
            UIAction(title: "Edit Code...", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.performSegue(withIdentifier: "showCodeEditor", sender: nil)
            },
            UIAction(title: "Import...", image: UIImage(systemName: "doc")) { _ in
                
            },
            UIAction(title: "Save...", image: UIImage(systemName: "square.and.arrow.down")) { _ in
                
            },
            UIAction(title: "Load...", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
            },
            UIAction(title: "Restart", image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
                self?.reset()
            },
        ])
        menuButton.showsMenuAsPrimaryAction = true
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
                    await self.scene.rotateInstructionPointer(to: direction)
                    currentDirection = direction
                case .stringMode(let stringModeOn):
                    self.stringModeLabel.isHidden = !stringModeOn
                case .move(let wrapped):
                    if wrapped {
                        await self.scene.wrapInstructionPointer(byMovingInDirection: currentDirection)
                    } else {
                        await self.scene.moveInstructionPointer(towards: currentDirection)
                    }
                case .playfieldChange(x: let x, y: let y, newInstruction: let newInstruction):
                    await self.scene.animatePlayfieldChange(x: x, y: y, newInstruction: newInstruction)
                case .terminate:
                    isTerminated = true
                    terminatedLabel.isHidden = false
                    stepButton.isEnabled = false
                    playPauseButton.isEnabled = false
                }
                outputLabel.scrollRectToVisible(CGRect(x: 0, y: outputLabel.contentSize.height - 1, width: 1, height: 1), animated: false)
            }
        }
        
    }
    
    func makeAnimationTask() -> Task<Void, Never> {
        Task { [weak self] in
            guard let `self` = self else { return }
            while !Task.isCancelled && !self.isTerminated {
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
        Task {
            animationTask = makeOneStepAnimationTask()
            await animationTask?.value
            animationTask = nil
        }
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
        } else if let vc = segue.destination as? CodeEditorViewController {
            vc.code = state.toSourceCode()
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
        DispatchQueue.main.async {
            SCLAlertView().showError("Error", subTitle: message, closeButtonTitle: "OK")
        }
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
            DispatchQueue.main.async {
                let alert = SCLAlertView(appearance: .init(showCloseButton: false))
                let textField = alert.addTextField("Input")
                alert.addButton("OK") {
                    continuation.resume(returning: textField.text ?? "")
                }
                alert.showEdit("Input", subTitle: prompt)
            }
        })
    }
    
    func reset() {
        animationTask?.cancel()
        animationTask = nil
        isPaused = true
        isTerminated = false
        stringModeLabel.isHidden = true
        terminatedLabel.isHidden = true
        updateOutputDisplay()
        inputCharBuffer = []
        outputBuffer = []
        playPauseButton.configuration?.image = UIImage(systemName: "play.fill")
        playPauseButton.isEnabled = true
        Task {
            await stackController.animateStack([])
        }
        state = State(io: self, code: code)
        scene = FungeWorldScene()
        scene.state = state
        scene.setup()
        sceneView.scene = scene
        sceneView.pointOfView = scene.cameraNode
        scene.camera = FungeWorldCamera(
                cameraNode: sceneView.pointOfView!)
    }
    
}

extension FungeWorldViewController: CodeEditorViewControllerDelegate {
    func didFinishEditingCode(code: String) {
        self.code = code
        reset()
    }
}
