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
}

