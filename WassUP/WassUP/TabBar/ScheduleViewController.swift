//
//  ScheduleViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController {

    
    @IBOutlet weak var backStackView: UIStackView!
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var listView: UICollectionView!
    
    @IBOutlet weak var notiButton: UIButton!
    
    var userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    var token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    var selectedDate = ""
    var selectDate = Date()
    
    var filtered : [Schedule.Format] = []
    var groupFiltered: [GroupSche.Format] = []
    var integrated: [Integrated] = []
    var seperated: [Integrated] = []
    var filteredIntegrated: [Integrated] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarConfigure()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        Schedule.shared.schedules = []
        GroupSche.shared3.groupSche = []
        filtered = []
        groupFiltered = []
        integrated = []
        
        let server = Server()
        server.getAllData(requestURL: "schedule", token: UserDefaults.standard.string(forKey: "token")!) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let dataArray = json?["data"] as? [[String: Any]] {
                        for dataEntry in dataArray {
                            if let userSchedules = dataEntry["userSchedules"] as? [[String: Any]] {
                                for scheduleEntry in userSchedules {
                                    parseUserScheduleEntry(scheduleEntry)
                                }
                            }
                            
                            if let groupSchedules = dataEntry["groupSchedules"] as? [[String: Any]] {
                                for scheduleEntry in groupSchedules {
                                    parseGroupScheduleEntry(scheduleEntry)
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async { [self] in
                        
                        
                        for i in 0..<filtered.count {
                            let integratedInstance = Integrated(originKey: filtered[i].originKey, groupOriginKey: "", name: filtered[i].name, userId: filtered[i].userId, startAt: filtered[i].startAt, endAt: filtered[i].endAt, memo: filtered[i].memo, allDayToggle: filtered[i].allDayToggle, color: filtered[i].color)
                            integrated.append(integratedInstance)
                        }

                        for i in 0..<groupFiltered.count {
                            let integratedInstance = Integrated(originKey: groupFiltered[i].originKey, groupOriginKey: groupFiltered[i].groupOriginKey, name: groupFiltered[i].name, userId: "", startAt: groupFiltered[i].startAt, endAt: groupFiltered[i].endAt, memo: groupFiltered[i].memo, allDayToggle: groupFiltered[i].allDayToggle, color: groupFiltered[i].color)
                            integrated.append(integratedInstance)
                        }
                        
                        seperated = seperateDate(data: integrated)
                        updateListView()
                        calendarReloadData()

                    }
                } catch {
                    print("JSON serialization error: \(error)")
                }
            }
        }
        
    }
    
    @IBAction func notiButtonTapped(_ sender: UIButton)  {
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
        let notificationVC = (storyboard.instantiateViewController(withIdentifier: "Notification") as? NotificationViewController)!
        present(notificationVC, animated: true)
                
    }
    
    
    @IBAction func changeCalendarMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            calendarView.setScope(.month, animated: true)
        } else {
            calendarView.setScope(.week, animated: true)
        }
    }
    
}

extension ScheduleViewController : FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        selectDate = date
        dateLabel.text = dateToString(dateFormatString: "M월 d일 E", date: date)
        seperated = seperateDate(data: integrated)
        updateListView()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var filteredIntegrated2 = seperated.filter { schedule in
            return schedule.startAt.contains(dateString)
        }
        
        return filteredIntegrated2.count
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
    // Calendar 주간, 월간 원활한 크기 변화를 위해
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarViewHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

extension ScheduleViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredIntegrated.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = listView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCell
        
        let schedule = filteredIntegrated[indexPath.item]
        
        cell.titleLabel.text = schedule.name
        if schedule.allDayToggle == "true" {
            cell.startHourLabel.text = "all Day"
            cell.endHourLabel.text = ""
            cell.minusLabel.text = ""
        } else {
            cell.startHourLabel.text = String(schedule.startAt.split(separator: "T")[1])
            cell.endHourLabel.text = String(schedule.endAt.split(separator: "T")[1])
            cell.minusLabel.text = "-"

        }
        
        cell.cellOriginKey = schedule.originKey
        cell.cellGroupOriginKey = schedule.groupOriginKey
        
        cell.backgroundColor = UIColor.white
        if cell.cellGroupOriginKey != "" {
            cell.marker.backgroundColor = UIColor(hexString: "ffffff")
            cell.backgroundColor = UIColor(hexString: "ebf0ff")
            cell.layer.cornerRadius = 10
        }
        else {
            cell.marker.backgroundColor = UIColor(hexString: String(schedule.color.dropFirst()))
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = listView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCell
        let schedule = filteredIntegrated[indexPath.item]
        
        let storyBoard = UIStoryboard(name: "Write", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Write") as! WriteViewController

        vc.name = schedule.name
        if schedule.allDayToggle == "true" {
            vc.flag = true
        } else {
            vc.flag = false
        }
        vc.startDateString = schedule.startAt
        vc.endDateString = schedule.endAt
        vc.memo = schedule.memo
        vc.color = String(schedule.color.dropFirst())
        vc.originKey = schedule.originKey
        vc.scheduleVC = self
        vc.groupOriginKey = schedule.groupOriginKey
        
        present(vc, animated: true)
    }
}

extension ScheduleViewController {
    func initView() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.setScope(.month, animated: true)
        backStackView.layer.cornerRadius = 20
        detailView.layer.cornerRadius = 20
        dateLabel.text = dateToString(dateFormatString: "M월 d일 E", date: selectDate)
        listView.dataSource = self
        listView.delegate = self
    }
    
    func dateToString(dateFormatString: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatString
        return dateFormatter.string(from: date)
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
    
    func parseUserScheduleEntry(_ entry: [String: Any]) {
        if let originKey = entry["originKey"] as? String,
           let name = entry["name"] as? String,
           let startAt = entry["startAt"] as? String,
           let endAt = entry["endAt"] as? String,
           let userId = entry["userId"] as? String,
           let memo = entry["memo"] as? String,
           let allDayToggle = entry["allDayToggle"] as? String,
           let color = entry["color"] as? String {
            
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
    
    func parseGroupScheduleEntry(_ entry: [String: Any]) {
        if let originKey = entry["originKey"] as? String,
           let groupOriginKey = entry["groupOriginKey"] as? String,
           let name = entry["name"] as? String,
           let startAt = entry["startAt"] as? String,
           let endAt = entry["endAt"] as? String,
           let memo = entry["memo"] as? String,
           let allDayToggle = entry["allDayToggle"] as? String,
           let color = entry["color"] as? String {
            
            let groupScheduleData = GroupSche.Format(
                originKey: originKey,
                groupOriginKey: groupOriginKey,
                name: name,
                startAt: startAt,
                endAt: endAt,
                memo: memo,
                allDayToggle: allDayToggle,
                color: color
            )
            
            GroupSche.shared3.updateGroupScheData(data: groupScheduleData)
            self.groupFiltered.append(groupScheduleData)
        }
    }
    
    func updateListView() {
     
        filteredIntegrated = seperated.filter { schedule in
            return schedule.startAt.contains(dateToString(dateFormatString: "yyyy-MM-dd", date: selectDate))
        }
        listView.reloadData()
    }
    
    func seperateDate(data: [Integrated]) -> [Integrated] {
        var seperated2 : [Integrated] = []
        for schedule in data {
            
            let startDay = String(schedule.startAt.split(separator: "T")[0])
            let endDay = String(schedule.endAt.split(separator: "T")[0])
            print("start and endDay \(startDay)")
            
            let startDayToDate = stringToDate(dateFormatString: "yyyy-MM-dd", dateString: startDay)
            let endDayToDate = stringToDate(dateFormatString: "yyyy-MM-dd", dateString: endDay)
            
            let comparisonResult = startDayToDate.compare(endDayToDate)
            
            if comparisonResult == .orderedAscending { // 일정이 2일 이상
                print("date1은 date2보다 이전입니다.")
                
                let dateDifference = calculateDateDifference(startAtDate: startDayToDate, endAtDate: endDayToDate)
                
                // 일정 시작 날
                var start = schedule
                var end = schedule
                
                start.endAt = startDay + "T23:59"
                seperated2.append(start)
                
                end.startAt = endDay + "T00:00"
                seperated2.append(end)
                
                // 중간에 껴있는 일정 수만큼 loop
                for i in 1..<Int(dateDifference.day!) {
                    var schedule = Integrated(originKey: schedule.originKey, groupOriginKey: schedule.groupOriginKey, name: schedule.name, userId: schedule.userId, startAt: calculateNextDay(startAtDate: startDayToDate, value: i)!, endAt: calculateNextDay(startAtDate: startDayToDate, value: i)!, memo: schedule.memo, allDayToggle: "true", color: schedule.color)
                    seperated2.append(schedule)
                }
                
            } else if comparisonResult == .orderedSame { // 당일 일정
                seperated2.append(schedule)
            }
        }
        return seperated2
        
    }
    func stringToDate(dateFormatString: String, dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatString
        return dateFormatter.date(from: dateString)!
    }
    func calculateDateDifference(startAtDate: Date, endAtDate: Date) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startAtDate, to: endAtDate)
        return components
    }
    func calculateNextDay(startAtDate: Date, value: Int) -> String? {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: value, to: startAtDate)
        return dateToString(dateFormatString: "yyyy-MM-dd", date: nextDay!)
    }

    
}

struct Integrated {
    var originKey: String
    var groupOriginKey : String
    var name: String
    var userId: String
    var startAt: String
    var endAt: String
    var memo: String
    var allDayToggle: String
    var color : String
}
