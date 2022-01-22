import UIKit
import Befunge

class CodeEditorView: UIScrollView {
    
    var textView: UITextView!
    var toolBar: UIToolbar!
    var keyboard: BefungeKeyboardView!
    
    var oneCharSize: CGSize = .zero
    
}
