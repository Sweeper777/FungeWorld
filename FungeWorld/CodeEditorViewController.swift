import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    override func viewDidLoad() {
    }
    
    @IBAction func doneDidTap() {
        
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
}
