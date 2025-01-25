//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit

private struct IndexCard {
    var title: String
    var img: UIImage
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

class ReorderInteractivelyController: UICollectionViewController {
    
    private var selectedIndices: Set<IndexPath> = []
    let toolbarTitlelLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        self.installsStandardGestureForInteractiveMovement = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        navigationItem.leftBarButtonItem = editButtonItem


        
        let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
        
        collectionView.register(MyCell.nib(), forCellWithReuseIdentifier: MyCell.reuseID)
        
        toolbarTitlelLabel.text = "фываф"
        toolbarTitlelLabel.textColor = .black
        toolbarTitlelLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toolbarTitlelLabel.textAlignment = .center
        toolbarTitlelLabel.sizeToFit() // Устанавливаем нужный размер

        let titleItem = UIBarButtonItem(customView: toolbarTitlelLabel)
        self.toolbarItems = [.flexibleSpace(), titleItem, .flexibleSpace(), removeButton]

        self.navigationController?.isToolbarHidden = true
    }
    
    
    @objc func remove() {
        selectedIndices.forEach{
            cards.remove(at: $0.row)
        }
        collectionView.deleteItems(at: Array(selectedIndices))
        selectedIndices.removeAll()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.visibleCells.forEach {
            let cell = $0 as! MyCell
            cell.selectable = editing
            let tempSelectedIndices = Array(selectedIndices)
            selectedIndices.removeAll()
            collectionView.reloadItems(at: tempSelectedIndices)
        }
        
        if (!editing) { self.navigationController?.isToolbarHidden = true }
    }
    
    @objc func longPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: recognizer.location(in: collectionView)) else {return }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
            break
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let item = cards.remove(at: sourceIndexPath.item)
        // Вставляем элемент на новое место
        cards.insert(item, at: destinationIndexPath.item)
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
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.reuseID, for: indexPath) as! MyCell
        
        cell.title.text = cards[indexPath.item].title
        cell.img.image = cards[indexPath.item].img
        cell.selectable = isEditing
        cell.cellSelected = selectedIndices.contains(indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isEditing else { return }
        if selectedIndices.contains(indexPath) {
            selectedIndices.remove(indexPath)
        } else {
            selectedIndices.insert(indexPath)
        }
        
        collectionView.reloadItems(at: [indexPath])
        
        navigationController?.isToolbarHidden =  selectedIndices.count == 0
        toolbarTitlelLabel.text = "\(selectedIndices.count) cards selected"
        toolbarTitlelLabel.sizeToFit()

    }
    
}
