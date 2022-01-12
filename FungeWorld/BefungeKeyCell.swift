import UIKit

class BefungeKeyCell: UICollectionViewCell {
    var key: String! {
        didSet {
            var attrString = AttributedString(key ?? "")
            attrString.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
            button.configuration?.attributedTitle = attrString
        }
    }
    
    
    @IBOutlet var button: UIButton!
    
    @IBAction func didTapButton() {
    }
    
    override func prepareForReuse() {
        key = nil
    }
}

