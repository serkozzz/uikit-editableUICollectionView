//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit

private let reuseIdentifier = "mycell"

private struct IndexCard : Hashable {
    var title: String
    var img: UIImage
    
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: IndexCard, rhs: IndexCard) -> Bool {
        lhs.id == rhs.id
    }
}

private var cards: [IndexCard] = [
    IndexCard(title: "Card 1", img: UIImage(systemName: "square.and.arrow.down.badge.xmark.fill")!),
    IndexCard(title: "Card 2", img: UIImage(systemName: "trash.slash")!),
    IndexCard(title: "Card 3", img: UIImage(systemName: "folder")!),
    IndexCard(title: "Card 4", img: UIImage(systemName: "tray.2")!),
    IndexCard(title: "Card 5", img: UIImage(systemName: "tray.circle")!),
    IndexCard(title: "Card 6", img: UIImage(systemName: "document.fill")!),
    IndexCard(title: "Card 7", img: UIImage(systemName: "exclamationmark.triangle.text.page.rtl")!),
    IndexCard(title: "Card 8", img: UIImage(systemName: "folder")!),
    IndexCard(title: "Card 9", img: UIImage(systemName: "tray.2")!),
    IndexCard(title: "Card 10", img: UIImage(systemName: "tray.circle")!),
    IndexCard(title: "Card 11", img: UIImage(systemName: "document.fill")!),
    IndexCard(title: "Card 12", img: UIImage(systemName: "exclamationmark.triangle.text.page.rtl")!),
    IndexCard(title: "Card 13", img: UIImage(systemName: "folder")!),
    IndexCard(title: "Card 14", img: UIImage(systemName: "tray.2")!),
    IndexCard(title: "Card 15", img: UIImage(systemName: "tray.circle")!),
    IndexCard(title: "Card 16", img: UIImage(systemName: "document.fill")!),
    IndexCard(title: "Card 17", img: UIImage(systemName: "exclamationmark.triangle.text.page.rtl")!),
]

class ReorderItemsInteractivelyExampleController: UICollectionViewController {
    
    private var selectedItems: Set<IndexCard> = []
    let toolbarTitlelLabel = UILabel()
    private var dataSource: UICollectionViewDiffableDataSource<Int, IndexCard>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        self.installsStandardGestureForInteractiveMovement = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        navigationItem.leftBarButtonItem = editButtonItem


        
        let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
        

        toolbarTitlelLabel.text = "фываф"
        toolbarTitlelLabel.textColor = .black
        toolbarTitlelLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toolbarTitlelLabel.textAlignment = .center
        toolbarTitlelLabel.sizeToFit() // Устанавливаем нужный размер

        let titleItem = UIBarButtonItem(customView: toolbarTitlelLabel)
        self.toolbarItems = [.flexibleSpace(), titleItem, .flexibleSpace(), removeButton]

        self.navigationController?.isToolbarHidden = true
        
        dataSource = UICollectionViewDiffableDataSource<Int, IndexCard>(collectionView: collectionView) { [weak self] collectionView, indexPath, card in
            
            guard let self else { return nil }
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
            
            cell.title.text = card.title
            cell.img.image = card.img
            cell.selectable = isEditing
            cell.cellSelected = selectedItems.contains(card)
            return cell
        }
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, IndexCard>()
        snapshot.appendSections([0])
        snapshot.appendItems(cards)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    @objc func remove() {

        cards.removeAll { selectedItems.contains($0) }
        applySnapshot()
        selectedItems.removeAll()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.visibleCells.forEach {
            let cell = $0 as! MyCollectionViewCell
            cell.selectable = editing
            let tempSelectedItems = Array(selectedItems)
            selectedItems.removeAll()
            
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems(tempSelectedItems)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        
        if (!editing) { self.navigationController?.isToolbarHidden = true }
    }
    
    @objc func longPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: recognizer.location(in: collectionView)) else { return }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
            
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let item = cards.remove(at: sourceIndexPath.item)
        // Вставляем элемент на новое место
        cards.insert(item, at: destinationIndexPath.item)
        
        applySnapshot()
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isEditing else { return }
        let item = cards[indexPath.item]
        
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, IndexCard>()
        snapshot.appendSections([0])
        snapshot.appendItems(cards)
        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        navigationController?.isToolbarHidden =  selectedItems.count == 0
        toolbarTitlelLabel.text = "\(selectedItems.count) cards selected"
        toolbarTitlelLabel.sizeToFit()

    }
    
}
