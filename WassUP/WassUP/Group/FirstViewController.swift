//
//  ViewController.swift
//  collectionViewTest2
//
//  Created by 유영재 on 2023/05/19.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var fourthCollectionView: UICollectionView!
    @IBOutlet weak var thirdCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var firstCollectionView: UICollectionView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    var groupOriginKey: String = ""
    var groupName: String = ""
    var groupSches : [Schedule.Format] = []
    
    
   
    var bars: [Bar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self
        
        secondCollectionView.delegate = self
        secondCollectionView.dataSource = self
        
        thirdCollectionView.delegate = self
        thirdCollectionView.dataSource = self
        
        fourthCollectionView.delegate = self
        fourthCollectionView.dataSource = self
        
        firstCollectionView.layer.borderWidth = 0.5
        secondCollectionView.layer.borderWidth = 0.5
        thirdCollectionView.layer.borderWidth = 0.5
        fourthCollectionView.layer.borderWidth = 0.5
        
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
                        for element in self.groupSches {
                            self.makeBar(startAt: element.startAt, endAt: element.endAt, userId: element.userId)
                            self.firstCollectionView.reloadData()
                            self.secondCollectionView.reloadData()
                            self.thirdCollectionView.reloadData()
                            self.fourthCollectionView.reloadData()
                            
                            print("3번 실행")
                        }
                    }
                }
            }
        }
            
//        for element in self.data {
//            self.makeBar(startAt: element.startAt, endAt: element.endAt, userId: element.userId)
//            firstCollectionView.reloadData()
//            secondCollectionView.reloadData()
//            thirdCollectionView.reloadData()
//            fourthCollectionView.reloadData()
//
//            print("3번 실행")
//        }
    }
    
    func makeBar(startAt: String, endAt: String, userId: String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm"
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
            updateMinutes()
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
                    bars[index].startMinute = "00"
                } else {
                    bars[index].startMinute = "30"
                    bars[index].startHour = bars[index].startHour + ".5"
                }
                
                if end < 30 {
                    bars[index].endMinute = "00"
                } else {
                    bars[index].endMinute = "30"
                    bars[index].endHour = bars[index].endHour + ".5"
                }
            }
            print("updated : \(bars)")
        }
    }
    
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupTimeTable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Second") as! SecondViewController
//        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    


}

extension FirstViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 480
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        for element in bars {
            if element.weekday == "1" {
                if collectionView == firstCollectionView {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//                    cell.nameLabel1.text = "\(indexPath.item)"
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = .black
                                print("userIndex: \(element.userIndex), indexPath.item: \(indexPath.item)")
                            }
                        }
                    }
                    return cell
                }
            }
            
            else if element.weekday == "2" {
                if collectionView == secondCollectionView {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//                    cell.nameLabel1.text = "\(indexPath.item)"
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = .black
                                print("userIndex: \(element.userIndex), indexPath.item: \(indexPath.item)")
                            }
                        }
                    }
                    return cell
                }
            }
            else if element.weekday == "3" {
                if collectionView == thirdCollectionView {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//                    cell.nameLabel1.text = "\(indexPath.item)"
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = .black
                                print("userIndex: \(element.userIndex), indexPath.item: \(indexPath.item)")
                            }
                        }
                    }
                    return cell
                }
            }
            else if element.weekday == "4" {
                if collectionView == fourthCollectionView {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//                    cell.nameLabel1.text = "\(indexPath.item)"
                    
                    // 사람찾기
                    if(Int(element.userIndex) == (indexPath.item % 10)) {
                        // 시간 parse
                        var startIndex = calculate(float: Float(element.startHour)!, index: element.userIndex)
                        var endIndex = calculate(float: Float(element.endHour)!, index: element.userIndex)
                        if(startIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        if(endIndex == indexPath.item) {
                            cell.backgroundColor = .black
                        }
                        for i in startIndex..<endIndex {
                            if ((i % 10) == Int(element.userIndex)!) && (i/10 == indexPath.item/10) {
                                cell.backgroundColor = .black
                                print("userIndex: \(element.userIndex), indexPath.item: \(indexPath.item)")
                            }
                        }
                    }
                    return cell
                }
            }
        }
//        if collectionView == firstCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//            cell.nameLabel1.text = "\(indexPath.item)"
//            if indexPath.item == 11 {
//                cell.nameLabel1.text = ""
//                cell.backgroundColor = .black
//            }
//            return cell
//        }
//        else if collectionView == secondCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//            cell.nameLabel2.text = "\(indexPath.item)"
//            if indexPath.item == 11 {
//                cell.nameLabel2.text = ""
//                cell.backgroundColor = .black
//            }
//            return cell
//        }
//        else if collectionView == thirdCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//            cell.nameLabel3.text = "\(indexPath.item)"
//
//            return cell
//        }
//        else if collectionView == fourthCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
//            cell.nameLabel4.text = "\(indexPath.item)"
//
//            return cell
//        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 10.5
        let cellHeight = collectionView.bounds.height / 48.3

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}
struct Format {
    var originKey: String
    var name: String
    var startAt: String
    var endAt: String
    var userId: String
    var memo: String
    var notification: String
    var allDayToggle: String
    var createdAt: String
    var lastModifiedAt: String
}

struct Bar {
    var userId: String
    var userIndex: String
    var startHour: String
    var startMinute: String
    var endHour: String
    var endMinute: String
    var weekday: String
}

