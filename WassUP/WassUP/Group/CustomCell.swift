//
//  CustomCell.swift
//  collectionViewTest2
//
//  Created by 유영재 on 2023/05/19.
//

import UIKit

class CustomCell: UICollectionViewCell {
    let bottomLineView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomLine()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBottomLine()
    }

    func setupBottomLine() {
        bottomLineView.backgroundColor = UIColor.lightGray // 하단 선의 색상을 원하는 색으로 변경
        contentView.addSubview(bottomLineView)
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true // 선의 높이를 원하는 값으로 변경
    }
    
    
}
