//
//  GroupScheduleCollectionViewCell.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/18.
//

import UIKit

class GroupScheduleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    var groupName: String = ""
    var groupOriginKey: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        markerView.layer.cornerRadius = 5
    }
}
