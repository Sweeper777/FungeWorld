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
        
        let line = String(repeating: "a", count: State.columns + 1)
        let fullPlayfield = Array(repeating: line, count: State.rows + 1).joined(separator: "\n")
        let unroundedSize = (fullPlayfield as NSString).size(withAttributes: [
            .font: font
        ])
        let unroundedCharSize = ("W" as NSString).size(withAttributes: [
            .font: font
        ])
        oneCharSize = CGSize(width: ceil(unroundedCharSize.width), height: ceil(unroundedCharSize.height))
 
        let size = CGSize(width: ceil(unroundedSize.width), height: ceil(unroundedSize.height))
        textView = UITextView(frame: CGRect(origin: .zero, size: size))
        
        keyboard = (UINib(nibName: "BefungeKeyboardView", bundle: nil)
                        .instantiate(withOwner: nil, options: nil).first as! BefungeKeyboardView)
        
        contentSize = size
        textView.layoutManager.showsInvisibleCharacters = true
        textView.inputView = keyboard
        textView.inputAccessoryView = toolBar
        keyboard.textInput = textView
        textView.spellCheckingType = .no
        textView.dataDetectorTypes = []
        textView.font = font
        textView.delegate = self
        textView.isScrollEnabled = false
    }
    
    func setupScrollView() {
        addSubview(textView)
        delegate = self
        keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
}
