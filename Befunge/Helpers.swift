import Foundation
infix operator %%: MultiplicationPrecedence

func %%<T: BinaryInteger>(lhs: T, rhs: T) -> T {
    (lhs % rhs + rhs) % rhs
}

