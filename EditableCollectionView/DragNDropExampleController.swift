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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        dataSource = UICollectionViewDiffableDataSource<Int, IndexCard>(collectionView: collectionView) { [weak self] collectionView, indexPath, card in
            
            guard let self else { return nil }
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
                
            cell.title.text = cards[indexPath.item].title
            cell.img.image = cards[indexPath.item].img
        
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
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
        
    }
}


extension DragNDropExampleController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let item = cards[indexPath.item].title as NSString
        let itemProvider = NSItemProvider(object: item)
        return [UIDragItem(itemProvider: itemProvider)]
    }

    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        let item = cards.remove(at: coordinator.items.first!.sourceIndexPath!.item)
        // Вставляем элемент на новое место
        cards.insert(item, at: destinationIndexPath.item)
        applySnapshot()
    }
}
