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
    
    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.edgeSpacing = .init(leading: .fixed(8), top: .fixed(8), trailing: .fixed(8), bottom: .fixed(8))
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(stackItemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
      
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}
