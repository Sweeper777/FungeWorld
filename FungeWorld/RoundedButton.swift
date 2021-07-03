import UIKit

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
    }
}
