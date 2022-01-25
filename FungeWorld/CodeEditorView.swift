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
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        setupTextView()
        setupScrollView()
    }
    func setupTextView() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard)),
            UIBarButtonItem(image: UIImage(systemName: "keyboard"), primaryAction: UIAction { [weak self] _ in
                guard let `self` = self else { return }
                if self.textView.inputView != nil {
                    self.textView.inputView = nil
                } else {
                    self.textView.inputView = self.keyboard
                }
                self.textView.reloadInputViews()
            }, menu: nil)
        ]
        
    }
    
    func setupScrollView() {
    }
}
