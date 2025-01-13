//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit

private let reuseIdentifier = "mycell"

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
]

class ReorderItemsInteractivelyExampleController: UICollectionViewController {
    
    var bottomNavBar: UINavigationBar!
    
    private var selectedIndices: Set<IndexPath> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        self.installsStandardGestureForInteractiveMovement = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        bottomNavBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let navigationItem = UINavigationItem(title: "My Title")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
        bottomNavBar.items = [navigationItem]
        view.addSubview(bottomNavBar)
        
        bottomNavBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        bottomNavBar.isHidden = true
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
            let cell = $0 as! MyCollectionViewCell
            cell.selectable = editing
            let tempSelectedIndices = Array(selectedIndices)
            selectedIndices.removeAll()
            collectionView.reloadItems(at: tempSelectedIndices)
        }
        bottomNavBar.isHidden = !editing
        
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
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
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
        
        bottomNavBar.isHidden =  selectedIndices.count == 0
    }
    
}
