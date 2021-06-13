import Foundation
infix operator %%: MultiplicationPrecedence

func %%<T: BinaryInteger>(lhs: T, rhs: T) -> T {
    (lhs % rhs + rhs) % rhs
}

public func printPlayfield(_ playfield: Array2D<UnicodeScalar>) {
    for row in (0..<playfield.rows) {
        for col in (0..<playfield.columns) {
            print(playfield[col, row], terminator: "")
        }
        print()
    }
}