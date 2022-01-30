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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maximumZoomScale = 1
        minimumZoomScale = min(width / contentSize.width,
                                min(height / contentSize.height, 1))
    }
 
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
 
        if let selectedTextRange = textView.selectedTextRange {
            let caretPositionRect = textView.caretRect(for: selectedTextRange.start)
 
            var x: CGFloat = contentOffset.x
 
            if caretPositionRect.minX - contentOffset.x < oneCharSize.width {
                x += (caretPositionRect.minX - contentOffset.x) - oneCharSize.width
                x = max(0, x)
            } else if ((caretPositionRect.minX - contentOffset.x) - frame.width) > -oneCharSize.width {
                x = caretPositionRect.minX - frame.width
                x += oneCharSize.width
                x = min(x, contentSize.width - frame.width)
            }
 
            contentOffset.x = x
            
            var y: CGFloat = contentOffset.y
 
            if caretPositionRect.minY - contentOffset.y < oneCharSize.height {
                y += (caretPositionRect.minY - contentOffset.y) - oneCharSize.height
                y = max(0, y)
            } else if ((caretPositionRect.minY - contentOffset.y) - frame.height) > -oneCharSize.height {
                y = caretPositionRect.minY - frame.height
                y += oneCharSize.height
                y = min(y, contentSize.height - frame.height)
            }
 
            contentOffset.y = y
        }
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let convertedRect = UIScreen.main.coordinateSpace.convert(rect, to: self.coordinateSpace)
            .intersection(self.bounds)
        let kbSize = convertedRect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: max(0, kbSize.height), right: 0)
        contentInset = insets
        scrollIndicatorInsets = insets
    }

    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        contentInset = UIEdgeInsets.zero
        scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func hideKeyboard() {
        endEditing(true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        textView
    }
    

}

extension CodeEditorView : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let lines = newText.split(separator: "\n")
        return lines.count <= State.rows && lines.allSatisfy { $0.count <= State.columns }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let range = textView.selectedTextRange else { return }
        let rect = textView.caretRect(for: range.end)
        guard !CGRect(origin: self.contentOffset, size: self.visibleSize).intersects(rect) else { return }
        self.scrollRectToVisible(rect, animated: true)
    }
}
