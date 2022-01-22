import UIKit
import Befunge

class CodeEditorView: UIScrollView {
    
    var textView: UITextView!
    var toolBar: UIToolbar!
    var keyboard: BefungeKeyboardView!
    
    var oneCharSize: CGSize = .zero
    
    var code: String? {
        get {
            textView?.text
        }
        set {
            textView?.text = newValue
        }
    }
    
    let font = UIFont.monospacedSystemFont(ofSize: 23, weight: .regular)
 
}
