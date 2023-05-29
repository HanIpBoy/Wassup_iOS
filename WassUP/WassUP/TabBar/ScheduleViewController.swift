//
//  ScheduleViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController {

    
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var notiButton: UIButton!
    var userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    var token: String = UserDefaults.standard.string(forKey: "token")!
    var filtered : [Schedule.Format] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarConfigure()
        print(UserDefaults.standard.string(forKey: "token"))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Schedule.shared.schedules = []
        filtered = []
        print(">>>>>> \(filtered)")
        let server = Server()
        server.getAllData(requestURL: "schedule/user-schedules", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let json = jsonObject as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    for dataEntry in dataArray {
                        if let originKey = dataEntry["originKey"] as? String {
                            let name = dataEntry["name"] as? String ?? ""
                            let startAt = dataEntry["startAt"] as? String ?? ""
                            let endAt = dataEntry["endAt"] as? String ?? ""
                            let userId = dataEntry["userId"] as? String ?? ""
                            let memo = dataEntry["memo"] as? String ?? ""
                            let allDayToggle = dataEntry["allDayToggle"] as? String ?? ""
                            let color = dataEntry["color"] as? String ?? ""
                            let scheduleData = Schedule.Format(
                                originKey: originKey,
                                name: name,
                                startAt: startAt,
                                endAt: endAt,
                                userId: userId,
                                memo: memo,
                                allDayToggle: allDayToggle,
                                color: color
                            )
                            
                            Schedule.shared.updateScheduleData(data: scheduleData)
                            self.filtered.append(scheduleData)
                        }
                    }
                    DispatchQueue.main.async {
                        self.calendarReloadData()
                    }
                }
            }
        }
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
    
    func calendarReloadData() {
        calendarView.reloadData()
    }
    
    @IBAction func notiButtonTapped(_ sender: UIButton)  {
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
        let notificationVC = (storyboard.instantiateViewController(withIdentifier: "Notification") as? NotificationViewController)!
        present(notificationVC, animated: true)
                
    }
    
}

extension ScheduleViewController : FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        vc.selectDate = date
        vc.selectedDate = dateFormatter.string(from: date)
        vc.scheduleVC = self
        
        present(vc, animated: true, completion: nil)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let filtered2 = filtered.filter { schedule in
            return schedule.startAt.contains(dateString)
        }
        return filtered2.count
        
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




