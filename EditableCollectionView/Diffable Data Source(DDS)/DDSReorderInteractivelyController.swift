//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit




class DDSReorderInteractivelyController: UICollectionViewController {
    
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
        
        collectionView.register(MyCell.nib(), forCellWithReuseIdentifier: MyCell.reuseID)
        dataSource = UICollectionViewDiffableDataSource<Int, IndexCard>(collectionView: collectionView) { [weak self] collectionView, indexPath, card in
            
            guard let self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.reuseID, for: indexPath) as! MyCell
            
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
    
        selectedItems.removeAll()
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let visibleItems = visibleIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
    
        reloadItems(visibleItems)
        
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
    
    private func reloadItems(_ items: [IndexCard]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isEditing else { return }
        let item = cards[indexPath.item]
        
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
        
        reloadItems([item])
        
        navigationController?.isToolbarHidden =  selectedItems.count == 0
        toolbarTitlelLabel.text = "\(selectedItems.count) cards selected"
        toolbarTitlelLabel.sizeToFit()

    }
    
}
