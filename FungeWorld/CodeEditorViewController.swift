import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        setupTextView()
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
        
    }
    
    
    @IBAction func doneDidTap() {
        
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
}

