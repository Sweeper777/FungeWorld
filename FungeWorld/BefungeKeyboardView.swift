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
    weak var textInput: UITextView!
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
    
    private func makeLayout() -> UICollectionViewLayout {
        
        let contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        
        func makeNumbersSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                 heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let rowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1/4))
            let zeroKeyItem = NSCollectionLayoutItem(layoutSize: rowGroupSize)
            item.contentInsets = contentInsets
            zeroKeyItem.contentInsets = contentInsets
          
            let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize,
                                                             subitem: item, count: 3)
            let sectionGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .absolute(150),
                                  heightDimension: .fractionalHeight(1)),
                subitems: [rowGroup, rowGroup, rowGroup, zeroKeyItem])
            
            let section = NSCollectionLayoutSection(group: sectionGroup)
            section.contentInsets = sectionInsets
            return section
        }
        
        func makeArithmeticLogicSection() -> NSCollectionLayoutSection {
            let arithItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(1/4))
            let arithItem = NSCollectionLayoutItem(layoutSize: arithItemSize)
            arithItem.contentInsets = contentInsets
            let logicItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(1/3))
            let logicItem = NSCollectionLayoutItem(layoutSize: logicItemSize)
            logicItem.contentInsets = contentInsets
            
            let columnGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/2),
                heightDimension: .fractionalHeight(1)
            )
            
            let arithGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: columnGroupSize,
                subitem: arithItem, count: 4)
            let logicGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: columnGroupSize,
                subitem: logicItem, count: 3)
            
            let sectionGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .absolute(100),
                                  heightDimension: .fractionalHeight(1)),
                subitems: [arithGroup, logicGroup])
            
            let section = NSCollectionLayoutSection(group: sectionGroup)
            section.contentInsets = sectionInsets
            return section
        }
        
        func makeOtherKeysSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(1/4))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = contentInsets
            
            let columnGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .absolute(50),
                                 heightDimension: .fractionalHeight(1)),
                subitems: [item])
            
            let section = NSCollectionLayoutSection(group: columnGroup)
            section.contentInsets = sectionInsets
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { i, env in
            switch i {
            case 0:
                return makeNumbersSection()
            case 1:
                return makeArithmeticLogicSection()
            default:
                return makeOtherKeysSection()
            }
        }, configuration: config)
        
        return layout
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
    
    func moveCursor(inDirection direction: UITextLayoutDirection) {
        guard let selectedTextRange = textInput.selectedTextRange else { return }

        let selectedPosition: UITextPosition
        if textInput.selectionAffinity == .backward {
            selectedPosition = selectedTextRange.start
        } else {
            selectedPosition = selectedTextRange.end
        }
        let positionAbove = textInput.position(from: selectedPosition, in: direction, offset: 1)
                        ?? textInput.beginningOfDocument
        textInput.selectedTextRange = textInput.textRange(from: positionAbove, to: positionAbove)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 400, height: 270)
    }
    
    @IBAction func didTapDeleteKey() {
        guard textInput.text.isNotNilNotEmpty else {
            return
        }
        
        var selectedRange = textInput.selectedRange
        if selectedRange.length == 0 {
            let newStart = max(0, selectedRange.location - 1)
            selectedRange = NSRange(location: newStart, length: 1)
        }
        if textInput.delegate?.textView?(textInput, shouldChangeTextIn: selectedRange, replacementText: "") == true {
            textInput.deleteBackward()
        }
    }
    
    @IBAction func didTapReturnKey() {
        insertText("\n")
    }
    
    @IBAction func didTapUpKey() {
        moveCursor(inDirection: .up)
    }
    
    @IBAction func didTapDownKey() {
        moveCursor(inDirection: .down)
    }
    
    @IBAction func didTapLeftKey() {
        moveCursor(inDirection: .left)
    }
    
    @IBAction func didTapRightKey() {
        moveCursor(inDirection: .right)
    }
    
    @IBAction func didTapSpaceKey() {
        insertText(" ")
    }
    
    func insertText(_ string: String) {
        let range = textInput.selectedRange
        if textInput.delegate?.textView?(textInput, shouldChangeTextIn: range, replacementText: string) == true {
            textInput.insertText(string)
        }
    }
}

extension BefungeKeyboardView: BefungeKeyCellDelegate {
    func didTapKey(_ key: String?) {
        insertText(key ?? "")
    }
}
