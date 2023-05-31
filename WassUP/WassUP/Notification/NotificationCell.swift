//
//  NotificationCell.swift
//  WassUP
//
//  Created by 유영재 on 2023/05/25.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var notificationVC :NotificationViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 10
        messageLabel.numberOfLines = 0
    }
    
    
}
