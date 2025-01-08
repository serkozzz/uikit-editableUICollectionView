//
//  MyCollectionViewCell.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
 
    
    @IBOutlet weak var selectionSignContrainer: UIView!
    @IBOutlet weak var selectedSign: UIImageView!
    @IBOutlet weak var unselectedSign: UIImageView!
    
    var selectable: Bool = false {
        didSet {
            selectionSignContrainer.isHidden = !selectable
        }
    }
    
    var cellSelected: Bool = false {
        didSet {
            selectedSign.isHidden = !cellSelected
            unselectedSign.isHidden = cellSelected
        }
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
}
