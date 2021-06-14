import XCTest
@testable import Befunge

class TestIO: IOProtocol {
    let numberSupplier: () -> Int
    let charSupplier: () -> UnicodeScalar

    var outputBuffer = ""
    var hasError = false

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
        hasError = true
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
        nextStep { [weak self] in
            if !(self?.terminated ?? true) {
                DispatchQueue.main.async {
                    self?.runUntilTerminated(completion: completion)
                }
            } else {
                completion()
            }
        }
    }
}

class BefungeTests: XCTestCase {

    func testSanity() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "9876543210 ..... ..... #@ Intentionally invalid instruction, should reflect")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertEqual(io.outputBuffer, "0 1 2 3 4 5 6 7 8 9 ")
            XCTAssertTrue(io.hasError)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testHelloWorld() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "64+\"!dlroW ,olleH\">:#,_@")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertEqual(io.outputBuffer, "Hello, World!\n")
            XCTAssertFalse(io.hasError)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testDNA() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "7^DN>vA\nv_#v? v\n7^<\"\"\"\"\n3  ACGT\n90!\"\"\"\"\n4*:>>>v\n+8^-1,<\n> ,+,@)")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertEqual(io.outputBuffer.filter("ACGT".contains).count, 56)
            XCTAssertFalse(io.hasError)
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testQuine() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertEqual(io.outputBuffer, "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@")
            XCTAssertFalse(io.hasError)
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }

}
