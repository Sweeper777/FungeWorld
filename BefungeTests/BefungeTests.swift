import XCTest
@testable import Befunge

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

extension State {
    func runUntilTerminated(completion: @escaping () -> Void) {
        nextStep {
            if !(self.terminated ?? true) {
                DispatchQueue.main.async {
                    self.runUntilTerminated(completion: completion)
                }
            } else {
                completion()
            }
        }
    }
}

class BefungeTests: XCTestCase {


    func testHelloWorld() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "64+\"!dlroW ,olleH\">:#,_@")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertEqual(io.outputBuffer, "Hello, World!\n")
        }
        wait(for: [expectation], timeout: 1)
    }

}
