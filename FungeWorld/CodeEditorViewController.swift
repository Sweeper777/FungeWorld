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
    
}

