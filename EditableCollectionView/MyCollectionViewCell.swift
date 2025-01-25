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
    
    @IBOutlet weak var draggingView: UIView!{
        didSet{
            print("draggingView has been set")
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
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
}

