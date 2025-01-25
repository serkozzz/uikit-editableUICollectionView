//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit


class DDSDragNDropController: UICollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Int, IndexCard>!
    private var isFirstDropUpdate = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.register(MyCell.nib(), forCellWithReuseIdentifier: MyCell.reuseID)

        dataSource = UICollectionViewDiffableDataSource<Int, IndexCard>(collectionView: collectionView) { collectionView, indexPath, card in
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.reuseID, for: indexPath) as! MyCell
                
            cell.title.text = cards[indexPath.item].title
            cell.img.image = cards[indexPath.item].img
            
            var backgroundConf = cell.defaultBackgroundConfiguration()
            backgroundConf.backgroundColor = .white
            backgroundConf.strokeColor = .darkGray
            backgroundConf.strokeWidth = 3
            cell.backgroundConfiguration = backgroundConf
            return cell
        }
        applySnapshot()
    }

    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, IndexCard>()
        snapshot.appendSections([0])
        snapshot.appendItems(cards)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
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


extension DDSDragNDropController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
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
        print("performDropWith")
        
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let dragItem = coordinator.items.first?.dragItem
        else { return }
        
        //model update
        let movedCard = cards.remove(at: coordinator.items.first!.sourceIndexPath!.item)
        cards.insert(movedCard, at: destinationIndexPath.item)
        
        
        let srcItemID = coordinator.session.localDragSession!.items.first!.localObject as! IndexCard
        let dstItemID = dataSource.itemIdentifier(for: destinationIndexPath)!
        
        let destCell = collectionView.cellForItem(at: destinationIndexPath)!
        
        let anim = coordinator.drop(dragItem, intoItemAt: destinationIndexPath, rect: destCell.bounds)
//        anim.addCompletion { _ in
//            if (srcItemID != dstItemID) {
//                self.applySnapshot()
//            }
//        }
    }
}
