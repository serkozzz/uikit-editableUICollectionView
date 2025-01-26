//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit


class ReorderInteractivelyController: UICollectionViewController {
    
    private var selectedIndices: Set<IndexPath> = []
    let toolbarTitlelLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        self.installsStandardGestureForInteractiveMovement = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        navigationItem.rightBarButtonItem = editButtonItem


        
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
