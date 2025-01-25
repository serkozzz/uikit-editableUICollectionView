//
//  MyCollectionViewCell.swift
//  EditableCollectionView
//
//  Created by Sergey Kozlov on 06.01.2025.
//

import UIKit

class MyCell: UICollectionViewCell {
 
    static let reuseID = "MyCell"
    static func nib() -> UINib { return UINib(nibName: "MyCell", bundle: nil)}
    
    @IBOutlet weak var selectionSignContrainer: UIView!
    @IBOutlet weak var selectedSign: UIImageView!
    @IBOutlet weak var unselectedSign: UIImageView!
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var draggingView: UIView!

    
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
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        print(state.cellDragState)
        if state.cellDragState == .dragging {
            draggingView.isHidden = false
        } else {
            draggingView.isHidden = true
        }
    }
    

}

