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

    func readNumber() async throws -> Int {
        numberSupplier()
    }
    
    func readChar() async throws -> UnicodeScalar {
        charSupplier()
    }
}

extension State {
    func runUntilTerminated() async -> Void {
        while !self.terminated {
            await nextStep()
        }
    }
}

class BefungeTests: XCTestCase {

    func testSanity() async {
        let io = TestIO()
        let state = State(io: io, code: "9876543210 ..... ..... #@ Intentionally invalid instruction, should reflect")
        await state.runUntilTerminated()
        XCTAssertEqual(io.outputBuffer, "0 1 2 3 4 5 6 7 8 9 ")
        XCTAssertTrue(io.hasError)
    }

    func testHelloWorld() async {
        let io = TestIO()
        let state = State(io: io, code: "64+\"!dlroW ,olleH\">:#,_@")
        await state.runUntilTerminated()
        XCTAssertEqual(io.outputBuffer, "Hello, World!\n")
        XCTAssertFalse(io.hasError)
    }

    func testDNA() async {
        let io = TestIO()
        let state = State(io: io, code: "7^DN>vA\nv_#v? v\n7^<\"\"\"\"\n3  ACGT\n90!\"\"\"\"\n4*:>>>v\n+8^-1,<\n> ,+,@)")
        await state.runUntilTerminated()
        XCTAssertEqual(io.outputBuffer.filter("ACGT".contains).count, 56)
        XCTAssertFalse(io.hasError)
        print(io.outputBuffer)
    }

    func testQuine() async {
        let io = TestIO()
        let state = State(io: io, code: "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@")
        await state.runUntilTerminated()
        XCTAssertEqual(io.outputBuffer, "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@")
        XCTAssertFalse(io.hasError)
        print(io.outputBuffer)
    }

    func testSieveOfEratosthenes() async {
        let io = TestIO()
        let state = State(io: io, code: "2>:3g\" \"-!v\\  g30          <\n |!`\"O\":+1_:.:03p>03g+:\"O\"`|\n @               ^  p3\\\" \":<\n2 234567890123456789012345678901234567890123456789012345678901234567890123456789")
        await state.runUntilTerminated()
        XCTAssertFalse(io.hasError)
        print(io.outputBuffer)
    }

    func testMycology() async {
        let io = TestIO()
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycology", withExtension: "b98")!);
        let state = State(io: io, code: code)
        await state.runUntilTerminated()
        XCTAssertFalse(io.hasError)
        XCTAssertFalse(io.outputBuffer.contains("BAD:"))
        print(io.outputBuffer)
    }

    func testMycorand() async {
        let io = TestIO()
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycorand", withExtension: "b98")!);
        let state = State(io: io, code: code)
        await state.runUntilTerminated()
        XCTAssertFalse(io.hasError)
        XCTAssertFalse(io.outputBuffer.contains("BAD:"))
        print(io.outputBuffer)
    }

    func testMycouser() async {
        let io = TestIO(numberSupplier: { Int.random(in: 1..<100) },
                charSupplier: { "abcdefghijklmnopqrstuvwxyz".randomElement()!.unicodeScalars.first! })
        let code = try! String(contentsOf: Bundle(identifier: "io.github.sweeper777.Befunge")!.url(forResource: "mycouser", withExtension: "b98")!);
        let state = State(io: io, code: code)
        await state.runUntilTerminated()
        XCTAssertFalse(io.outputBuffer.contains("BAD:"))
        print(io.outputBuffer)
    }
}
