//
//  ListCell.swift
//  WassUP
//
//  Created by 김진웅 on 2023/06/01.
//

import UIKit

class ListCell: UICollectionViewCell {
    
    @IBOutlet weak var marker: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    
    var cellOriginKey: String = ""
    var cellGroupOriginKey: String = ""
    
    override func awakeFromNib() {
       super.awakeFromNib()
       marker.layer.cornerRadius = 5
   }
    
}
