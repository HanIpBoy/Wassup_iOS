//
//  NotificationCell.swift
//  WassUP
//
//  Created by 유영재 on 2023/05/25.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var notificationVC :NotificationViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        messageLabel.numberOfLines = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // borderBottom을 가진 CALayer 생성
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.black.cgColor
        borderLayer.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)

        // 셀의 레이어에 borderBottom 추가
        self.layer.addSublayer(borderLayer)
    }
    
    
}
