//
//  IndexCard.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 25.01.2025.
//

import UIKit

struct IndexCard : Hashable {
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


var cards = [
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
