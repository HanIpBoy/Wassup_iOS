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

    @IBOutlet weak var loadingView: UIView!
    
    
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

    var groupVC: GroupViewController!

    var groupOriginKey: String = ""
    var groupName: String = ""
    var groupDescription: String = ""
    var leaderId: String = ""
        
    var bars: [Bar] = []
    var baseDate: Date = Date()
    
    var startDateOfWeek: Date = Date()
    var endDateOfWeek: Date = Date()
    var startDateOfWeekKR: Date = Date()
    var endDateOfWeekKR: Date = Date()

    var groupUsers : [String: Any] = [:]
    var groupIDs : [String] = []
    var groupUsersName : [String]?
    var buttons: [UIButton] = []

    var integrated: [IntegratedSchedule.Format]!
    
    let loadingViewController = LoadingViewController()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        print("&&& 2")

        if let loadingView = loadingViewController.view {
            addChild(loadingViewController)
            loadingView.frame = self.loadingView.bounds
            self.loadingView.addSubview(loadingView)
            loadingViewController.didMove(toParent: self)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [self] in
            // LoadingViewController의 뷰를 loadingView에 추가
            makeDataSourceAndDelegate(collectionView: firstCollectionView)
            makeDataSourceAndDelegate(collectionView: secondCollectionView)
            makeDataSourceAndDelegate(collectionView: thirdCollectionView)
            makeDataSourceAndDelegate(collectionView: fourthCollectionView)
            makeDataSourceAndDelegate(collectionView: fifthCollectionView)
            makeDataSourceAndDelegate(collectionView: sixthCollectionView)
            makeDataSourceAndDelegate(collectionView: seventhCollectionView)
            // loadingView가 3초동안 천천히 흐려지다가 완전히 안보이게끔 해줘
            UIView.animate(withDuration: 3.0, animations: {
                self.loadingView.alpha = 0.0
            }, completion: { _ in
                // 애니메이션이 완료된 후, loadingView를 제거합니다.
                self.loadingViewController.willMove(toParent: nil)
                self.loadingViewController.view.removeFromSuperview()
                self.loadingViewController.removeFromParent()
            })

        }
        
        groupIDs = groupUsers["groupUsers"] as! [String]
        myView.layer.cornerRadius = 20
        
        
        
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("&&& 1")
        let server = Server()
        integrated = []
        
        // 백그라운드 큐에서 데이터 요청 및 처리 작업 수행
        DispatchQueue.global().async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            server.getAllData(requestURL: "group/user/schedule/\(self.groupOriginKey)", token: UserDefaults.standard.string(forKey: "token")!) { [weak self] (data, response, error) in
                defer {
                    dispatchGroup.leave()
                }
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        if let dataArray = json?["data"] as? [[String: Any]] {
                            for dataEntry in dataArray {
                                print(">>1")
                                if let userId = dataEntry["userId"] as? String,
                                   let groupSchedules = dataEntry["groupSchedules"] as? [[String: Any]],
                                   let userSchedules = dataEntry["userSchedules"] as? [[String: Any]] {
                                    print(">>2")
                                    if let userSchedules = dataEntry["userSchedules"] as? [[String: Any]] {
                                        for scheduleEntry in userSchedules {
                                            self?.parseUserScheduleEntry(scheduleEntry)
                                            print(">>3")
                                        }
                                    }
                                    
                                    if let groupSchedules = dataEntry["groupSchedules"] as? [[String: Any]] {
                                        for scheduleEntry in groupSchedules {
                                            self?.parseGroupScheduleEntry(scheduleEntry, userId)
                                            print(">>4")
                                        }
                                    }
                                    
                                }
                            }
                            DispatchQueue.main.async {
                                self!.reloadDate()
                            }
                        }
                    } catch {
                        print("JSON serialization error: \(error)")
                    }
                }
            }
            
            dispatchGroup.wait() // 모든 비동기 작업 완료 대기
            
            dispatchGroup.enter()
            server.postDataToServer(requestURL: "group/search/userName", requestData: self.groupUsers, token: UserDefaults.standard.string(forKey: "token")!) { [weak self] (data, response, error) in
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
                                self?.groupUsersName = groupData.groupUsers
                                print("leaderId in server req : \(groupData.leaderId)")
                            }
                        }
                        DispatchQueue.main.async {
                            if let names = self!.groupUsersName{
                                for i in 0..<(names.count) {

                                    self!.buttons[i].isHidden = false

                                    self!.buttons[i].setTitle((String(names[i].dropFirst())), for: .normal)
                                    self!.buttons[i].layer.cornerRadius = 15
                                }
                            }
                        }
                    }
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.wait() // 모든 비동기 작업 완료 대기
        }
        
        
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
            
            let scheduleData = IntegratedSchedule.Format(
                originKey: originKey,
                groupOriginKey: "",
                name: name,
                userId: userId,
                startAt: startAt,
                endAt: endAt,
                memo: memo,
                allDayToggle: allDayToggle,
                color: color
            )
            integrated.append(scheduleData)
//            IntegratedSchedule.shared4.updateIntegrated(data: scheduleData)
        }
    }
    
    func parseGroupScheduleEntry(_ entry: [String: Any], _ userId: String) {
        if let originKey = entry["originKey"] as? String,
           let groupOriginKey = entry["groupOriginKey"] as? String,
           let name = entry["name"] as? String,
           let userId = userId as? String,
           let startAt = entry["startAt"] as? String,
           let endAt = entry["endAt"] as? String,
           let memo = entry["memo"] as? String,
           let allDayToggle = entry["allDayToggle"] as? String,
           let color = entry["color"] as? String {
            
            let groupScheduleData = IntegratedSchedule.Format(
                originKey: originKey,
                groupOriginKey: groupOriginKey,
                name: name,
                userId: userId,
                startAt: startAt,
                endAt: endAt,
                memo: memo,
                allDayToggle: allDayToggle,
                color: color
            )
            integrated.append(groupScheduleData)
//            IntegratedSchedule.shared4.updateIntegrated(data: groupScheduleData)
            
        }
    }
    
    func makeBar(_ element: IntegratedSchedule.Format) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let startDate = dateFormatter.date(from: element.startAt)
        let endDate = dateFormatter.date(from: element.endAt)

        let calendar = Calendar.current

        // 요일 정보 얻기, 1부터 시작, 일요일부터 시작
        let weekday = calendar.component(.weekday, from: (startDate!))

        // 시작 시간 얻기
        let startHour = calendar.component(.hour, from: (startDate)!)
        let startMinute = calendar.component(.minute, from: (startDate)!)

        var endHour = calendar.component(.hour, from: (endDate)!)
        let endMinute = calendar.component(.minute, from: (endDate)!)
        var userIndex = ""
        
        if endMinute == 0 {
            if endHour != 0 {
                endHour -= 1
            }
        }
        
        for i in 0..<groupIDs.count {
            if element.userId == groupIDs[i] {
                userIndex = String(i+1)
            }
        }
        
        if groupOriginKey == element.groupOriginKey { // 내가 선택한 그룹의 그룹일정일때
            userIndex = "11"
        }
        

        let bar: Bar = Bar(userId: element.userId, userIndex: userIndex, startHour: String(startHour), startMinute: String(startMinute), endHour: String(endHour), endMinute: String(endMinute), weekday: String(weekday))

        bars.append(bar)
        print("bar : \(bar)")
    }

    
    func calculate(float : Float, index: String) -> Int {
        let hour = Int(float)
        let userIndex = Int(index)!

        return (hour*13)+userIndex
    }
    
    @IBAction func dismissTimeTable(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func groupNameTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "GroupSchedule", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupScheduleViewController") as? GroupScheduleViewController else { return }
        vc.groupName = groupName
        vc.groupOriginKey = groupOriginKey
        vc.groupDescription = groupDescription
        vc.leaderId = leaderId
        vc.groupVC = groupVC
        vc.groupTimeTableVC = self
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
        return 312
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        if !bars.isEmpty {
            cell.backgroundColor = UIColor.clear
            for element in bars {
                if element.weekday == "1" {
                    if collectionView == firstCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            

                            for i in startIndex..<endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)

                                }
                            }
                        }
                    }
                }

                else if element.weekday == "2" {
                    if collectionView == secondCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "3" {
                    if collectionView == thirdCollectionView {
                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "4" {
                    if collectionView == fourthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)

                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "5" {
                    if collectionView == fifthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "6" {
                    if collectionView == sixthCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            let startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            let endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            print("element : \(element)")
                            print("start/endHour : \(element.startHour) , \(element.endHour)")
                            print("start/endIndex : \(startIndex) , \(endIndex)")
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                }
                            }
                        }
                    }
                }
                
                else if element.weekday == "7" {
                    if collectionView == seventhCollectionView {

                        // 사람찾기
                        if(Int(element.userIndex) == (indexPath.item % 13)) {
                            // 시간 parse
                            var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                            var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                            for i in startIndex...endIndex {
                                if ((i % 13) == Int(element.userIndex)!) && (i/13 == indexPath.item/13) {
                                    cell.backgroundColor = colorVendingMachine(index: element.userIndex)
                                }
                            }
                        }
                    }
                }
            }
            
            return cell
        }
        else {
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 13
        let cellHeight = collectionView.bounds.height / 24

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
            
            let final = self.seperateDate(data: self.integrated)
            
            for element in final {
                let elementDate = dateFormatter.date(from:element.startAt) // bar로 만들 데이터의 시작 날짜
                let elementDateKR = calendar.date(byAdding: .second, value: timeZone?.secondsFromGMT(for: elementDate!) ?? 0, to: elementDate!)
                
                if isDate(elementDateKR!, between: self.startDateOfWeekKR, and: self.endDateOfWeekKR) { // 바로 만들 데이터의 시작날짜가 기준에 포함하는지
                    self.makeBar(element) // 기준 통과시 바 생성
                }
                
            }
        }

        DispatchQueue.main.async {
            
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
    func measureExecutionTime() {
        let startTime = DispatchTime.now()
        
        // 측정하고자 하는 코드 작성
        // ...
        
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let executionTime = Double(nanoTime) / 1_000_000_000 // 초 단위로 변환
        
        print("Execution time: \(executionTime) seconds")
    }
    
    func seperateDate(data: [IntegratedSchedule.Format]) -> [IntegratedSchedule.Format] {
        var seperated2 : [IntegratedSchedule.Format] = []
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
                    var schedule = IntegratedSchedule.Format(originKey: schedule.originKey, groupOriginKey: schedule.groupOriginKey, name: schedule.name, userId: schedule.userId, startAt: calculateNextDay(startAtDate: startDayToDate, value: i)!+"T00:00", endAt: calculateNextDay(startAtDate: startDayToDate, value: i)!+"T23:59", memo: schedule.memo, allDayToggle: "true", color: schedule.color)
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
    func dateToString(dateFormatString: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatString
        return dateFormatter.string(from: date)
    }


    
}


