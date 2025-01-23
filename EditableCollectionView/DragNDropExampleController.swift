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
    ]

class DragNDropExampleController: UICollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Int, IndexCard>!
    private var isFirstDropUpdate = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        dataSource = UICollectionViewDiffableDataSource<Int, IndexCard>(collectionView: collectionView) { collectionView, indexPath, card in
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
                
            cell.title.text = cards[indexPath.item].title
            cell.img.image = cards[indexPath.item].img
            cell.backgroundColor = .lightGray
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
    
    
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}


extension DragNDropExampleController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: NSString())
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = cards[indexPath.item]
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: any UIDragSession) {
        isFirstDropUpdate = true
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        
        // Skipping the first update.
        // Otherwise UICollectionView will set dragged state for the wring cell.
        if isFirstDropUpdate {
            isFirstDropUpdate = false
            return UICollectionViewDropProposal(operation: .move)
        }
        
        if let dstIdxPath = destinationIndexPath {
        
            let srcItemID = session.localDragSession!.items.first!.localObject as! IndexCard
            let dstItemID = dataSource.itemIdentifier(for: dstIdxPath)!
            
            if dstItemID != srcItemID {
                let srcIdxPath = dataSource.indexPath(for: srcItemID)!
                var snap = dataSource.snapshot()
                if dstIdxPath.item > srcIdxPath.item {
                    snap.moveItem(srcItemID, afterItem: dstItemID)
                } else {
                    snap.moveItem(srcItemID, beforeItem: dstItemID)
                }
                dataSource.apply(snap)
            }
        }
        
        return UICollectionViewDropProposal(operation: .move)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let dragItem = coordinator.items.first?.dragItem
        else { return }
        
        //model update
        let movedCard = cards.remove(at: coordinator.items.first!.sourceIndexPath!.item)
        cards.insert(movedCard, at: destinationIndexPath.item)
        
        
        let srcItemID = coordinator.session.localDragSession!.items.first!.localObject as! IndexCard
        let dstItemID = dataSource.itemIdentifier(for: destinationIndexPath)!

        let anim = coordinator.drop(dragItem, toItemAt: destinationIndexPath)
        anim.addCompletion { _ in
            if (srcItemID != dstItemID) {
                self.applySnapshot()
            }
        }
    }
}
