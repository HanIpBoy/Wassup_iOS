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
    var cellOriginKey: String = ""
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        // 셀의 테두리 스타일과 색상을 지정합니다.
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.black.cgColor
//    }
    
}
