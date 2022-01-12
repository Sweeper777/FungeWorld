import UIKit

private enum Section: CaseIterable {
    case numbers
    case arithmeticAndLogic
    case directions
    case stack
    case io
}

private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

class BefungeKeyboardView: UIView {
    weak var textInput: UITextInput!
    @IBOutlet var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

