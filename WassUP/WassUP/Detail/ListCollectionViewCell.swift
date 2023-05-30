//
//  ListCollectionViewCell.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/15.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var colorMarker: UIView!
    
    var cellGroupOriginKey: String = ""
    var cellOriginKey: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorMarker.layer.cornerRadius = 5
    }
    
}
