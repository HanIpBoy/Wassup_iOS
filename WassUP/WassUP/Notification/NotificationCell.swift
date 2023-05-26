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
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        // 셀의 뷰 구성 설정
        layer.cornerRadius = 10 // 원하는 모서리 반경 값으로 설정
        layer.borderWidth = 1 // 원하는 테두리 두께 값으로 설정
        layer.borderColor = UIColor.black.cgColor // 원하는 테두리 색상으로 설정
    }
}
