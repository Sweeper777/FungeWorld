import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    weak var delegate: CodeEditorViewControllerDelegate?
    
    override func viewDidLoad() {
    }
    
    @IBAction func doneDidTap() {
        
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
}

protocol CodeEditorViewControllerDelegate: AnyObject {
    func didFinishEditingCode(code: String)
}
