//
//  CustomCell.swift
//  collectionViewTest2
//
//  Created by 유영재 on 2023/05/19.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
//    @IBOutlet weak var nameLabel4: UILabel!
//    @IBOutlet weak var nameLabel3: UILabel!
//    @IBOutlet weak var nameLabel2: UILabel!
//    @IBOutlet weak var nameLabel1: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.lightGray.cgColor
    }
//    override init(frame: CGRect) {
//            super.init(frame: frame)
//
//            // 셀의 경계선 스타일과 색상을 설정합니다.
//            layer.borderWidth = 1.0
//            layer.borderColor = UIColor.lightGray.cgColor
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//        }
    
}
