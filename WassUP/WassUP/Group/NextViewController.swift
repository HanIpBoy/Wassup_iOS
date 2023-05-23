//
//  NextViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/23.
//

import UIKit

class NextViewController: UIViewController {
    
    @IBOutlet weak var thirdCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var firstCollectionView: UICollectionView!

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!


    @IBOutlet weak var groupUserBtn1: UIButton!
    @IBOutlet weak var groupUserBtn2: UIButton!
    @IBOutlet weak var groupUserBtn3: UIButton!
    @IBOutlet weak var groupUserBtn4: UIButton!
    @IBOutlet weak var groupUserBtn5: UIButton!
    @IBOutlet weak var groupUserBtn6: UIButton!
    @IBOutlet weak var groupUserBtn7: UIButton!
    @IBOutlet weak var groupUserBtn8: UIButton!
    @IBOutlet weak var groupUserBtn9: UIButton!
    @IBOutlet weak var groupUserBtn10: UIButton!


    var groupOriginKey: String = ""
    var groupName: String = ""
    var groupSches : [Schedule.Format] = []

    var bars: [Bar] = []
    var baseDate: Date = Date()
    var startDateOfWeek: Date = Date()
    var endDateOfWeek: Date = Date()
    var groupUsers : [String: Any] = [:]
    var groupUsersName : [String]?
    var buttons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self

        secondCollectionView.delegate = self
        secondCollectionView.dataSource = self

        thirdCollectionView.delegate = self
        thirdCollectionView.dataSource = self

        firstCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        secondCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        thirdCollectionView.layer.borderColor = UIColor.lightGray.cgColor

        firstCollectionView.layer.borderWidth = 0.5
        secondCollectionView.layer.borderWidth = 0.5
        thirdCollectionView.layer.borderWidth = 0.5

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        groupNameLabel.text = groupName



        buttons.append(groupUserBtn1)
        buttons.append(groupUserBtn2)
        buttons.append(groupUserBtn3)
        buttons.append(groupUserBtn4)
        buttons.append(groupUserBtn5)
        buttons.append(groupUserBtn6)
        buttons.append(groupUserBtn7)
        buttons.append(groupUserBtn8)
        buttons.append(groupUserBtn9)
        buttons.append(groupUserBtn10)

        for element in buttons {
            element.isHidden = true
        }


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
                        }
                    }

                    DispatchQueue.main.async {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                        
                        let calendar = Calendar(identifier: .gregorian)
                        let timeZone = TimeZone(identifier: "Asia/Seoul")
                        
                        let baseDateKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.baseDate) ?? 0, to: self.baseDate)
                        // UTC 시간대의 Date 객체를 한국 시간대로 변환
                        (self.startDateOfWeek, self.endDateOfWeek) = self.getPreviousSundayAndCurrentSaturday(today: baseDateKR!)
                        let startDateOfWeekKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.startDateOfWeek) ?? 0, to: self.startDateOfWeek)
                        let endDateOfWeekKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.endDateOfWeek) ?? 0, to: self.endDateOfWeek)
                                                    
                        for element in self.groupSches {
                            let elementDate = dateFormatter.date(from:element.startAt) // bar로 만들 데이터의 시작 날짜
                            let elementDateKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: elementDate!) ?? 0, to: elementDate!)
                            
                            if self.isDate(elementDateKR!, between: startDateOfWeekKR!, and: endDateOfWeekKR!) { // 바로 만들 데이터의 시작날짜가 기준에 포함하는지
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
        server.postDataToServer(requestURL: "group/search/userName", requestData: groupUsers, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let json = jsonObject as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    for dataEntry in dataArray {
                        if let groupUsers = dataEntry["groupUsers"] as? [String] {
                            let groupName = dataEntry["groupName"] as? String ?? ""
                            let description = dataEntry["description"] as? String ?? ""
                            let numOfUsers = dataEntry["numOfUsers"] as? Int ?? 0
                            let leaderId = dataEntry["leaderId"] as? String ?? ""


                            let groupData = Group.Format(
                                originKey: "",
                                groupName: groupName,
                                description: description,
                                numOfUsers: numOfUsers,
                                leaderId: leaderId,
                                groupUsers: groupUsers
                            )
                            self.groupUsersName = groupData.groupUsers
                        }
                    }
                    DispatchQueue.main.async {
                        if let names = self.groupUsersName{
                            for i in 0..<(names.count) {
                                
                                print("\(names[i]) \n")
                                self.buttons[i].isHidden = false
                                // buttons[i].titleLabel?.text로 지정 시 초기화 됨.
                                self.buttons[i].setTitle(String(names[i].dropFirst()), for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }

    
    func makeBar(startAt: String, endAt: String, userId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let startDate = dateFormatter.date(from: startAt)
        let endDate = dateFormatter.date(from: endAt)

        let calendar = Calendar.current

        // 요일 정보 얻기, 1부터 시작, 일요일부터 시작
        let weekday = calendar.component(.weekday, from: (startDate!))

        // 시작 시간 얻기
        let startHour = calendar.component(.hour, from: (startDate)!)
        let startMinute = calendar.component(.minute, from: (startDate)!)

        let endHour = calendar.component(.hour, from: (endDate)!)
        let endMinute = calendar.component(.minute, from: (endDate)!)

        let bar: Bar = Bar(userId: userId, userIndex: "", startHour: String(startHour), startMinute: String(startMinute), endHour: String(endHour), endMinute: String(endMinute), weekday: String(weekday))

        bars.append(bar)
        makeUserIndex(content: bars)
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
    }

    func calculate(float : Float, index: String) -> Int {
        let hour = Int(float)
        let userIndex = Int(index)!

        return (hour*10)+userIndex
    }

    func updateMinutes() {
        for index in 0..<bars.count {
            if let start = Int(bars[index].startMinute), let end = Int(bars[index].endMinute) {
                if start < 30 {
                    bars[index].startMinute = "30"
                } else {
                    bars[index].startMinute = "00"
                    var stringToInt = Int(bars[index].startHour)!
                    stringToInt += 1
                    bars[index].startHour = String(stringToInt)
                }

                if end < 30 {
                    bars[index].endMinute = "30"
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
        
        // 이번주 일요일 찾기
        let sundayComponent = DateComponents(weekday: 1)
        guard let currentSunday = calendar.nextDate(after: today, matching: sundayComponent, matchingPolicy: .nextTime) else {
            fatalError("Failed to calculate current Sunday.")
        }
        
        return (previousSunday, currentSunday)
    }

    func isDate(_ date: Date, between startDate: Date, and endDate: Date) -> Bool {
        return date >= startDate && date < endDate
    }


    @IBAction func showGroupSches(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupSchedule", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupScheduleViewController") as? GroupScheduleViewController else { return }
        vc.groupName = groupName
        vc.groupOriginKey = groupOriginKey
        self.present(vc, animated: true, completion: nil)
    }


    @IBAction func nextButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "GroupTimeTable", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "Second") as! SecondViewController
//        vc.modalTransitionStyle = .crossDissolve
//        vc.groupName = self.groupName
//        vc.groupOriginKey = self.groupOriginKey
//
//        self.present(vc, animated: true)
        
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

extension NextViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
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
                }
            }
            
            else if element.weekday == "6" {
                if collectionView == secondCollectionView {
                    
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
                }
            }
            else if element.weekday == "7" {
                if collectionView == thirdCollectionView {
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
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 10.5
        let cellHeight = collectionView.bounds.height / 24.1
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}



