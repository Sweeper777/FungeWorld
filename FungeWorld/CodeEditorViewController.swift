import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    weak var delegate: CodeEditorViewControllerDelegate?
    
    @IBOutlet var codeEditor: CodeEditorView!
    override func viewDidLoad() {
        codeEditor.code = code
    }
    
    @IBAction func doneDidTap() {
        delegate?.didFinishEditingCode(code: codeEditor.code ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
}

protocol CodeEditorViewControllerDelegate: AnyObject {
    func didFinishEditingCode(code: String)
}
