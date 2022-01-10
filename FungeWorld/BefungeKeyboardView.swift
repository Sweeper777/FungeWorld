import UIKit


class BefungeKeyboardView: UIView {
    weak var textInput: UITextInput!
    @IBOutlet var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

