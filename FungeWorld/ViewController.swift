import UIKit
import Befunge

class TestIO: IOProtocol {
    let numberSupplier: () -> Int
    let charSupplier: () -> UnicodeScalar

    var outputBuffer = ""

    init(numberSupplier: @escaping () -> Int = { fatalError() },
         charSupplier: @escaping () -> UnicodeScalar = { fatalError() }) {
        self.numberSupplier = numberSupplier
        self.charSupplier = charSupplier
    }

    func writeChar(_ char: UnicodeScalar) {
        outputBuffer += "\(char)"
    }

    func writeInt(_ int: Int) {
        outputBuffer += "\(int) "
    }

    func writeError(_ message: String) {
        print("Error: \(message)")
    }

    func readNumber(completion: @escaping (Int) -> Void) {
        completion(numberSupplier())
    }

    func readChar(completion: @escaping (UnicodeScalar) -> Void) {
        completion(charSupplier())
    }


}

class ViewController: UIViewController {
    let io = TestIO()
    lazy var state = State(io: io, code: "64+\"!dlroW ,olleH\">:#,_@")
    override func viewDidLoad() {
        super.viewDidLoad()
        print(io.outputBuffer)
        printPlayfield(state.playfield)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        state.nextStep {
            print("Instruction Pointer: \(self.state.instructionPointer)")
            print("Stack: \(self.state.stack)")
            print("String Mode: \(self.state.stringMode)")
        }
    }
}

