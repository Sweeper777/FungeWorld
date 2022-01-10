import UIKit
import Befunge

class CodeEditorViewController: UIViewController {
    
    var code: String?
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBAction func doneDidTap() {
        
    }
    
    @IBAction func cancelDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
}

