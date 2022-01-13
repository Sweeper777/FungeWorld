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
    private lazy var dataSource = makeDataSource()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "BefungeKeyCell", bundle: nil), forCellWithReuseIdentifier: "cell")

        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        fillCollectionView()
    }
    
    private func fillCollectionView() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            toSection: .numbers)
        snapshot.appendItems(
            ["+", "-", "*", "/", "%", "!", "`"],
            toSection: .arithmeticAndLogic)
        snapshot.appendItems(
            ["^", "<", ">", "v", "?", "|", "_", "#"],
            toSection: .directions)
        snapshot.appendItems(
            ["\"", ":", "\\", "$"],
            toSection: .stack)
        snapshot.appendItems(
            [".", ",", "&", "~", "p", "g", "@"],
            toSection: .io)
        dataSource.apply(snapshot)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, model) ->
                UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath) as? BefungeKeyCell
                cell?.key = model
                cell?.delegate = self
                return cell
            })
        return dataSource
    }
    
}

