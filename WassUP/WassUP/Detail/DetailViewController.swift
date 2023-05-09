//
//  DetailViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/04.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    var selectedDate: String = "" // FSCal에서 선택된 날짜를 저장할 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = selectedDate // FSCal에서 선택된 날짜를 변수에 저장하고 텍스트로 지정
        
    }
    

}
