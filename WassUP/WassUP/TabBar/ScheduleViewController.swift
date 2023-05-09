//
//  HomeViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController {

    
    @IBOutlet weak var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarConfigure()
    }
    
    func calendarConfigure() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        // Style
        calendarView.layer.cornerRadius = 20
        calendarView.headerHeight = 50
        calendarView.weekdayHeight = 20
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // header의 이번 달만 표시
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleColor = .label
        
        // Style - event
        calendarView.appearance.eventDefaultColor = .systemBlue
        calendarView.appearance.eventSelectionColor = .systemMint
        
        // Style - 오늘 및 선택 원형 색깔
        calendarView.appearance.todayColor = .gray
        calendarView.appearance.selectionColor = UIColor(hexString: "0040ff")
        
        // Style - 글자 색
        calendarView.appearance.titleDefaultColor = .label
        calendarView.appearance.titleTodayColor = .label
        calendarView.appearance.titleSelectionColor = .white
        calendarView.appearance.weekdayTextColor = .label
        
        // functional
        calendarView.locale = Locale(identifier: "ko_KR")
        
        
    }
    
    
    
    
    

}

extension ScheduleViewController : FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 (E)"
        vc.selectedDate = dateFormatter.string(from: date)
        
        
        present(vc, animated: true, completion: nil)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, weekdayTextColorFor weekday: Int) -> UIColor? {
        if weekday == 1 {
            return .systemRed
        } else if weekday == 7 {
            return .systemBlue
        } else {
            return .label
        }
    }
}


