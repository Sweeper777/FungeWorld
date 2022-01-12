import UIKit

class BefungeKeyCell: UICollectionViewCell {
    var key: String! {
        didSet {
            var attrString = AttributedString(key ?? "")
            attrString.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
            button.configuration?.attributedTitle = attrString
        }
    }
    
    weak var delegate: BefungeKeyCellDelegate?
    
    @IBOutlet var button: UIButton!
    
    @IBAction func didTapButton() {
        delegate?.didTapKey(key)
    }
    
    override func prepareForReuse() {
        delegate = nil
        key = nil
    }
}

protocol BefungeKeyCellDelegate: AnyObject {
    func didTapKey(_ key: String?)
}
