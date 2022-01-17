import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    @IBOutlet var scrollView: UIScrollView!
    var textView: UITextView!
    var toolBar: UIToolbar!
    var keyboard: BefungeKeyboardView!
    
    override func viewDidLoad() {
        setupTextView()
        setupScrollView()
    }
    
    let font = UIFont.monospacedSystemFont(ofSize: 23, weight: .regular)
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    func setupTextView() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing)),
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
        let size = CGSize(width: ceil(unroundedSize.width), height: ceil(unroundedSize.height))
        textView = UITextView(frame: CGRect(origin: .zero, size: size))
        
        keyboard = (UINib(nibName: "BefungeKeyboardView", bundle: nil)
                        .instantiate(withOwner: nil, options: nil).first as! BefungeKeyboardView)
        
        scrollView.contentSize = size
        textView.layoutManager.showsInvisibleCharacters = true
        textView.inputView = keyboard
        textView.inputAccessoryView = toolBar
        keyboard.textInput = textView
        textView.spellCheckingType = .no
        textView.dataDetectorTypes = []
        textView.font = font
        textView.text = code
        textView.delegate = self
        textView.isScrollEnabled = false
    }
    
    func setupScrollView() {
        scrollView.addSubview(textView)
//        scrollView.keyboardDismissMode = .interactive
        scrollView.delegate = self
        scrollView.keyboardDismissMode = .none
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = min(scrollView.width / scrollView.contentSize.width,
                                          min(scrollView.height / scrollView.contentSize.height, 1))
    }
    
    @IBAction func doneDidTap() {
        
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        guard UIDevice.isPhone else { return }
        
        // FIXME: Wrong coordinate system
        
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let kbSize = rect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension CodeEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        textView
    }
}

extension CodeEditorViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let range = textView.selectedTextRange else { return }
        let rect = textView.caretRect(for: range.end)
        guard !CGRect(origin: scrollView.contentOffset, size: scrollView.visibleSize).intersects(rect) else { return }
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}
