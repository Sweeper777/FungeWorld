import UIKit

private enum Section: CaseIterable {
    case main
}

private struct StackItem: Hashable {
    let value: Int
    let color: UIColor
}

private typealias DataSource = UICollectionViewDiffableDataSource<Section, StackItem>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StackItem>

class BefungeStackViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var dataSource = makeDataSource()
    
    let stackItemHeight = CGFloat(44)
}
