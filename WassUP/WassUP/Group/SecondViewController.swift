//
//  SecondViewController.swift
//  collectionViewTest2
//
//  Created by 김진웅 on 2023/05/20.
//

import UIKit

class SecondViewController: UIViewController {

//    @IBOutlet weak var fourthCollectionView: UICollectionView!
    @IBOutlet weak var thirdCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var firstCollectionView: UICollectionView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    var groupOriginKey: String = ""
    var groupName: String = ""
    var groupSches : [Schedule.Format] = []
    
//    var data : [Format] = [
//        Format(originKey: "", name: "", startAt: "2023-05-18-17:14", endAt: "2023-05-18-18:14", userId: "ingjwjw@naver.com", memo: "", notification: "", allDayToggle: "false", createdAt: "", lastModifiedAt: ""),
//        Format(originKey: "", name: "", startAt: "2023-05-19-18:14", endAt: "2023-05-19-19:14", userId: "ing@naver.com", memo: "", notification: "", allDayToggle: "false", createdAt: "", lastModifiedAt: ""),
//        Format(originKey: "", name: "", startAt: "2023-05-20-20:14", endAt: "2023-05-20-23:14", userId: "ingjwjw@naver.com", memo: "", notification: "", allDayToggle: "false", createdAt: "", lastModifiedAt: ""),
//        Format(originKey: "", name: "", startAt: "2023-05-18-06:14", endAt: "2023-05-18-10:14", userId: "ing@naver.com", memo: "", notification: "", allDayToggle: "false", createdAt: "", lastModifiedAt: "")]
    
    var bars: [Bar] = []
    var baseDate: Date = Date()
    var startDateOfWeek: Date = Date()
    var endDateOfWeek: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self
        
        secondCollectionView.delegate = self
        secondCollectionView.dataSource = self
        
        thirdCollectionView.delegate = self
        thirdCollectionView.dataSource = self
        
        firstCollectionView.layer.borderWidth = 0.5
        secondCollectionView.layer.borderWidth = 0.5
        thirdCollectionView.layer.borderWidth = 0.5

        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        groupNameLabel.text = groupName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Schedule.shared.groupSchedules = []
        groupSches = []
        let server = Server()
        server.getAllData(requestURL: "group/\(groupOriginKey)/user-schedules", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            print("3번")
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
                            
                            let scheduleData = Schedule.Format(
                                originKey: originKey,
                                name: name,
                                startAt: startAt,
                                endAt: endAt,
                                userId: userId,
                                memo: memo,
                                allDayToggle: allDayToggle
                            )
                            
                            Schedule.shared.updateGroupScheduleData(data: scheduleData)
                            self.groupSches.append(scheduleData)
                            print("groupSches : \(self.groupSches)")
                        }
                    }
                    DispatchQueue.main.async {
                        // 날짜를 기준으로 범위 설정
                        (self.startDateOfWeek, self.endDateOfWeek) = self.getPreviousSundayAndCurrentSaturday(today: self.baseDate)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        for element in self.groupSches {
                            let elementDate = dateFormatter.date(from:element.startAt) // bar로 만들 데이터의 시작 날짜
                            if self.isDate(elementDate!, between: self.startDateOfWeek, and: self.endDateOfWeek) { // 바로 만들 데이터의 시작날짜가 기준에 포함하는지
                                self.makeBar(startAt: element.startAt, endAt: element.endAt, userId: element.userId) // 기준 통과시 바 생성
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.updateMinutes()
                        self.firstCollectionView.reloadData()
                        self.secondCollectionView.reloadData()
                        self.thirdCollectionView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func makeBar(startAt: String, endAt: String, userId: String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let startDate = dateFormatter.date(from: startAt)
            let endDate = dateFormatter.date(from: endAt)
            
            let calendar = Calendar.current
            
            // 요일 정보 얻기, 1부터 시작, 일요일부터 시작
            let weekday = calendar.component(.weekday, from: (startDate)!)
            
            // 시작 시간 얻기
            let startHour = calendar.component(.hour, from: (startDate)!)
            let startMinute = calendar.component(.minute, from: (startDate)!)

            let endHour = calendar.component(.hour, from: (endDate)!)
            let endMinute = calendar.component(.minute, from: (endDate)!)
            
            let bar: Bar = Bar(userId: userId, userIndex: "", startHour: String(startHour), startMinute: String(startMinute), endHour: String(endHour), endMinute: String(endMinute), weekday: String(weekday))
            
            bars.append(bar)
            makeUserIndex(content: bars)
//            updateMinutes()
        }
        
    func makeUserIndex(content: [Bar]) {
        var selected: [String] = []
        for bar in content {
            if !selected.contains(bar.userId) {
                selected.append(bar.userId)
            }
        }
        for (index, userId) in selected.enumerated() {
            for (barIndex, bar) in content.enumerated() {
                if bar.userId == userId {
                    bars[barIndex].userIndex = String(index)
                }
            }
        }
        // 최종적인 바 데이터
        print("Updated bars: \(bars)")
    }
    
    func calculate(float : Float, index: String) -> Int {
        var hour = Int(float)
        var userIndex = Int(index)!
        
        return (hour*20)+userIndex
    }
    
    func updateMinutes() {
        for index in 0..<bars.count {
            if let start = Int(bars[index].startMinute), let end = Int(bars[index].endMinute) {
                if start < 30 {
                    bars[index].startMinute = "30"
                    bars[index].startHour = bars[index].startHour + ".5"
                } else {
                    bars[index].startMinute = "00"
                    var stringToInt = Int(bars[index].startHour)!
                    stringToInt += 1
                    bars[index].startHour = String(stringToInt)
                }
                
                if end < 30 {
                    bars[index].endMinute = "30"
                    bars[index].endHour = bars[index].endHour + ".5"
                } else {
                    bars[index].endMinute = "00"
                    var stringToInt = Int(bars[index].endHour)!
                    stringToInt += 1
                    bars[index].endHour = String(stringToInt)
                }
            }
        }
    }
    
    func getPreviousSundayAndCurrentSaturday(today : Date) -> (previousSunday: Date, currentSaturday: Date) {
        let calendar = Calendar.current
        
        // 전주 일요일 찾기
        let sundayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let previousSunday = calendar.date(from: sundayComponents) else {
            fatalError("Failed to calculate previous Sunday.")
        }
        
        // 이번주 토요일 찾기
        let currentSaturdayComponents = DateComponents(weekday: 7)
        guard let currentSaturday = calendar.nextDate(after: today, matching: currentSaturdayComponents, matchingPolicy: .nextTime) else {
            fatalError("Failed to calculate current Saturday.")
        }
        
        return (previousSunday, currentSaturday)
    }
    
    func isDate(_ date: Date, between startDate: Date, and endDate: Date) -> Bool {
        return date >= startDate && date <= endDate
    }

    
    
    
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupTimeTable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "First") as! FirstViewController
        vc.modalTransitionStyle = .crossDissolve
        
        dismiss(animated: true, completion: nil)
    }
    
    func colorVendingMachine(index : String) -> UIColor {
        switch index {
        case "0" : return .red
        case "1" : return .orange
        case "2" : return .yellow
        case "3" : return .green
        case "4" : return .cyan
        case "5" : return .blue
        case "6" : return .purple
        case "7" : return .systemPink
        case "8" : return .black
        case "9" : return .brown
        default: return .darkGray
        }
    }
    

}

extension SecondViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 240
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        for element in bars {
            if element.weekday == "5" {
                if collectionView == firstCollectionView {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                            }
                        }
                    }
//                    return cell
                }
            }
            
            else if element.weekday == "6" {
                if collectionView == secondCollectionView {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                            }
                        }
                    }
//                    return cell
                }
            }
            else if element.weekday == "7" {
                if collectionView == thirdCollectionView {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell

                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                            }
                        }
                    }
//                    return cell
                }
            }
        }
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 10.5
        let cellHeight = collectionView.bounds.height / 24.5

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}
