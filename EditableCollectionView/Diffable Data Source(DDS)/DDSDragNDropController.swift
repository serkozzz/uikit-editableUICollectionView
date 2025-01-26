//
//  MyCollectionViewController.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit


class DDSDragNDropController: UICollectionViewController {

    private var dataSource: UICollectionViewDiffableDataSource<Int, IndexCard>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dragInteractionEnabled = true // Включить drag
        
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
        dataSource.reorderingHandlers.canReorderItem = { _ in true }
        dataSource.reorderingHandlers.didReorder = { transaction in
            if let applyingResult = cards.applying(transaction.difference) {
                cards = applyingResult
            }
        }
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
