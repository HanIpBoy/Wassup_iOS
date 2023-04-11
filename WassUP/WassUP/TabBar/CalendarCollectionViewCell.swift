//
//  CalendarCollectionViewCell.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/28.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    func update(day: String) {
        self.dayLabel.text = day
        
    }
}
