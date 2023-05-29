//
//  GroupTimeTableViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/25.
//

import UIKit

class GroupTimeTableViewController: UIViewController {
    
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var seventhCollectionView: UICollectionView!
    @IBOutlet weak var sixthCollectionView: UICollectionView!
    @IBOutlet weak var fifthCollectionView: UICollectionView!
    @IBOutlet weak var fourthCollectionView: UICollectionView!
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
    var baseDate: Date = Date() // 주의 기간을 잡기 위한 기준 날짜
//    기본 값은 오늘이되, Next에서 오왼 스와이프 시 baseDate 값을 일주일 늘려서 전달
//    First에서, 왼오 스와이프 시 baseDate 값을 일주일 빼서 Next로 전달
    
//    스와이프 :
//    First에서
//      왼오 : 이전 주의 Next 뷰컨을 present로 띄우기
//      오왼 : 그냥 Next 뷰컨
//    Next에서
//      왼오 : 그냥 dismiss
//      오왼 : 다음 주의 First뷰컨을 띄워야 하기 때문에, Next 뷰컨의 baseDate에 baseDate + 일주일을 저장하고 present
    var startDateOfWeek: Date = Date()
    var endDateOfWeek: Date = Date()
    var startDateOfWeekKR: Date = Date()
    var endDateOfWeekKR: Date = Date()

    var groupUsers : [String: Any] = [:]
    var groupIDs : [String] = []
    var groupUsersName : [String]?
    var buttons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        groupIDs = groupUsers["groupUsers"] as! [String]
        myView.layer.cornerRadius = 20
        
        makeDataSourceAndDelegate(collectionView: firstCollectionView)
        makeDataSourceAndDelegate(collectionView: secondCollectionView)
        makeDataSourceAndDelegate(collectionView: thirdCollectionView)
        makeDataSourceAndDelegate(collectionView: fourthCollectionView)
        makeDataSourceAndDelegate(collectionView: fifthCollectionView)
        makeDataSourceAndDelegate(collectionView: sixthCollectionView)
        makeDataSourceAndDelegate(collectionView: seventhCollectionView)
        
        makeBorderForCollectionView(collectionView: firstCollectionView)
        makeBorderForCollectionView(collectionView: secondCollectionView)
        makeBorderForCollectionView(collectionView: thirdCollectionView)
        makeBorderForCollectionView(collectionView: fourthCollectionView)
        makeBorderForCollectionView(collectionView: fifthCollectionView)
        makeBorderForCollectionView(collectionView: sixthCollectionView)
        makeBorderForCollectionView(collectionView: seventhCollectionView)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

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
        
        groupNameLabel.text = groupName
        
        let labelTouch = UITapGestureRecognizer(target: self, action: #selector(groupNameTapped))
        groupNameLabel.addGestureRecognizer(labelTouch)
        
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
                            let color = dataEntry["color"] as? String ?? ""
                            let allDayToggle = dataEntry["allDayToggle"] as? String ?? ""

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
                            Schedule.shared.updateGroupScheduleData(data: scheduleData)
                            self.groupSches.append(scheduleData)
                        }
                    }
                    self.reloadDate()
                    
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

                                print("names : \(names[i]) \n")
                                self.buttons[i].isHidden = false

                                self.buttons[i].setTitle((String(names[i].dropFirst())), for: .normal)
                                self.buttons[i].layer.cornerRadius = 15
                            }
                        }
                    }

                }
            }
        }
        
        
        
        
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        Schedule.shared.groupSchedules = []
//        groupSches = []
//        let server = Server()
//        server.getAllData(requestURL: "group/\(groupOriginKey)/user-schedules", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            if let data = data {
//                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//                   let json = jsonObject as? [String: Any],
//                   let dataArray = json["data"] as? [[String: Any]] {
//                    for dataEntry in dataArray {
//                        if let originKey = dataEntry["originKey"] as? String {
//                            let name = dataEntry["name"] as? String ?? ""
//                            let startAt = dataEntry["startAt"] as? String ?? ""
//                            let endAt = dataEntry["endAt"] as? String ?? ""
//                            let userId = dataEntry["userId"] as? String ?? ""
//                            let memo = dataEntry["memo"] as? String ?? ""
//
//                            let allDayToggle = dataEntry["allDayToggle"] as? String ?? ""
//
//                            let scheduleData = Schedule.Format(
//                                originKey: originKey,
//                                name: name,
//                                startAt: startAt,
//                                endAt: endAt,
//                                userId: userId,
//                                memo: memo,
//                                allDayToggle: allDayToggle
//                            )
//                            Schedule.shared.updateGroupScheduleData(data: scheduleData)
//                            self.groupSches.append(scheduleData)
//                        }
//                    }
//                    self.reloadDate()
//
//                }
//            }
//
//        }
//        server.postDataToServer(requestURL: "group/search/userName", requestData: groupUsers, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            if let data = data {
//                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//                   let json = jsonObject as? [String: Any],
//                   let dataArray = json["data"] as? [[String: Any]] {
//                    for dataEntry in dataArray {
//                        if let groupUsers = dataEntry["groupUsers"] as? [String] {
//                            let groupName = dataEntry["groupName"] as? String ?? ""
//                            let description = dataEntry["description"] as? String ?? ""
//                            let numOfUsers = dataEntry["numOfUsers"] as? Int ?? 0
//                            let leaderId = dataEntry["leaderId"] as? String ?? ""
//
//
//                            let groupData = Group.Format(
//                                originKey: "",
//                                groupName: groupName,
//                                description: description,
//                                numOfUsers: numOfUsers,
//                                leaderId: leaderId,
//                                groupUsers: groupUsers
//                            )
//                            self.groupUsersName = groupData.groupUsers
//                        }
//                    }
//                    DispatchQueue.main.async {
//                        if let names = self.groupUsersName{
//                            for i in 0..<(names.count) {
//
//                                print("names : \(names[i]) \n")
//                                self.buttons[i].isHidden = false
//
//                                self.buttons[i].setTitle((String(names[i].dropFirst())), for: .normal)
//                                self.buttons[i].layer.cornerRadius = 15
//                            }
//                        }
//                    }
//
//                }
//            }
//        }
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
        var userIndex = ""
        for i in 0..<groupIDs.count {
            if userId == groupIDs[i] {
                userIndex = String(i)
            }
        }

        let bar: Bar = Bar(userId: userId, userIndex: userIndex, startHour: String(startHour), startMinute: String(startMinute), endHour: String(endHour), endMinute: String(endMinute), weekday: String(weekday))

        bars.append(bar)
    }

    
    func calculate(float : Float, index: String) -> Int {
        let hour = Int(float)
        let userIndex = Int(index)!

        return (hour*10)+userIndex
    }
    
    @IBAction func dismissTimeTable(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func groupNameTapped(_ sender: UITapGestureRecognizer) {
        print("touched")
        let storyboard = UIStoryboard(name: "GroupSchedule", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupScheduleViewController") as? GroupScheduleViewController else { return }
        vc.groupName = groupName
        vc.groupOriginKey = groupOriginKey
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func previousWeekAction(_ sender: UIButton) {
        let calendar = Calendar(identifier: .gregorian)
        baseDate = calendar.date(byAdding: .weekOfYear, value: -1, to: baseDate) ?? Date()
        
        reloadDate()
    }
    
    @IBAction func nextWeekAction(_ sender: UIButton) {
        let calendar = Calendar(identifier: .gregorian)
        baseDate = calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate) ?? Date()
        reloadDate()
    }
}

extension GroupTimeTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        if !bars.isEmpty {
            cell.backgroundColor = colorVendingMachine(index: "10")
            for element in bars {
                if element.weekday == "1" {
                    if collectionView == firstCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex..<endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("1 : \(indexPath.item)")

                                }
                            }
                        }
                    }
                }

                else if element.weekday == "2" {
                    if collectionView == secondCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("2 : \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "3" {
                    if collectionView == thirdCollectionView {
                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("3 : \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "4" {
                    if collectionView == fourthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("4 : \(indexPath.item) : \(startIndex) : \(endIndex)")
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "5" {
                    if collectionView == fifthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("5 : \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "6" {
                    if collectionView == sixthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("6 : \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "7" {
                    if collectionView == seventhCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 10)) {
                            // 시간 parse
                            var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                    print("7 : \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
            }
            
            return cell
        }
        else {
            cell.backgroundColor = colorVendingMachine(index: "10")
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 10.0
        let cellHeight = collectionView.bounds.height / 24.1

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint.zero
    }
}

extension GroupTimeTableViewController {
    private func makeDataSourceAndDelegate(collectionView: UICollectionView){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func reloadDate() {
        bars = []
        DispatchQueue.main.async {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            
            let calendar = Calendar(identifier: .gregorian)
            let timeZone = TimeZone(identifier: "Asia/Seoul")
            
            let baseDateKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.baseDate) ?? 0, to: self.baseDate)
            // UTC 시간대의 Date 객체를 한국 시간대로 변환
            (self.startDateOfWeek, self.endDateOfWeek) = getPreviousSundayAndCurrentSaturday(today: baseDateKR!)
            self.startDateOfWeekKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.startDateOfWeek) ?? 0, to: self.startDateOfWeek)!
            self.endDateOfWeekKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: self.endDateOfWeek) ?? 0, to: self.endDateOfWeek)!
            
            for element in self.groupSches {
                let elementDate = dateFormatter.date(from:element.startAt) // bar로 만들 데이터의 시작 날짜
                let elementDateKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: elementDate!) ?? 0, to: elementDate!)
                
                if isDate(elementDateKR!, between: self.startDateOfWeekKR, and: self.endDateOfWeekKR) { // 바로 만들 데이터의 시작날짜가 기준에 포함하는지
                    self.makeBar(startAt: element.startAt, endAt: element.endAt, userId: element.userId) // 기준 통과시 바 생성
                }
                
            }
        }
        
        DispatchQueue.main.async {
            print("bars : \(self.bars)")
            
            self.firstCollectionView.reloadData()
            self.secondCollectionView.reloadData()
            self.thirdCollectionView.reloadData()
            self.fourthCollectionView.reloadData()
            self.fifthCollectionView.reloadData()
            self.sixthCollectionView.reloadData()
            self.seventhCollectionView.reloadData()
            
            self.periodLabel.text = makePeriodLabel(startDate: self.startDateOfWeekKR, endDate: self.endDateOfWeekKR)
            
        }
    }
}
