import UIKit

private enum Section: CaseIterable {
    case main
}

private struct StackItem: Hashable {
    let value: Int
    let color: UIColor
    let id = UUID()
}

private typealias DataSource = UICollectionViewDiffableDataSource<Section, StackItem>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StackItem>

class BefungeStackViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var dataSource = makeDataSource()
    
    let stackItemHeight = CGFloat(44)
    
    private var stack: [Int] = []
    
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: "BefungeStackCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        collectionView.transform = .init(scaleX: 1, y: -1)
    }
    
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
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, model) ->
                UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath) as? BefungeStackCell
                cell?.valueLabel.text = "\(model.value)"
                cell?.backgroundColor = model.color
                DispatchQueue.main.async {
                    cell?.transform = .init(scaleX: 1, y: -1)
                }
                return cell
            })
        return dataSource
    }
    
    func animateStack(_ stack: [Int]) async {
        self.stack = stack
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(stack.map { .init(value: $0, color: .yellow) })
        view.layoutIfNeeded()
        await UIView.asyncAnimate(withDuration: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.collectionViewHeightConstraint.constant =
                snapshot.numberOfItems.f * self.stackItemHeight
            if snapshot.numberOfItems == 0 {
                self.collectionViewHeightConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        await dataSource.apply(snapshot, animatingDifferences: true)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: stack.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func animatePush(_ item: Int) async {
        stack.append(item)
        await animateStack(stack)
    }
    func animatePop() async {
        if stack.isNotEmpty {
            stack.removeLast()
            await animateStack(stack)
        }
    }
}

extension UIView {
    @discardableResult
    static func asyncAnimate(withDuration duration: TimeInterval, animations: @escaping () -> Void)
        async -> Bool
    {
        await withCheckedContinuation { continuation in
            UIView.animate(withDuration: duration, animations: animations) { completed in
                continuation.resume(returning: completed)
            }
        }
    }
}
