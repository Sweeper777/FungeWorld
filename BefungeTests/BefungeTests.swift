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

    func readNumber() async -> Int {
        numberSupplier()
    }
    
    func readChar() async -> UnicodeScalar {
        charSupplier()
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

    func testSieveOfEratosthenes() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let state = State(io: io, code: "2>:3g\" \"-!v\\  g30          <\n |!`\"O\":+1_:.:03p>03g+:\"O\"`|\n @               ^  p3\\\" \":<\n2 234567890123456789012345678901234567890123456789012345678901234567890123456789")
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertFalse(io.hasError)
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMycology() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycology", withExtension: "b98")!);
        let state = State(io: io, code: code)
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertFalse(io.hasError)
            XCTAssertFalse(io.outputBuffer.contains("BAD:"))
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMycorand() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO()
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycorand", withExtension: "b98")!);
        let state = State(io: io, code: code)
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertFalse(io.hasError)
            XCTAssertFalse(io.outputBuffer.contains("BAD:"))
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMycouser() throws {
        let expectation = XCTestExpectation(description: "program terminates")
        let io = TestIO(numberSupplier: { Int.random(in: 1..<100) },
                charSupplier: { "abcdefghijklmnopqrstuvwxyz".randomElement()!.unicodeScalars.first! })
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycouser", withExtension: "b98")!);
        let state = State(io: io, code: code)
        state.runUntilTerminated {
            expectation.fulfill()
            XCTAssertFalse(io.outputBuffer.contains("BAD:"))
            print(io.outputBuffer)
        }
        wait(for: [expectation], timeout: 1)
    }
}
