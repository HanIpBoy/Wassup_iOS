//
//  DetailViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/04.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var listView: UICollectionView!
    
    var selectedDate: String = "" // FSCal에서 선택된 날짜를 저장할 변수
    var selectDate: Date?
    
    var filteredSchedules: [Schedule.Format] = []
    var filteredGroupSchedules: [GroupSche.Format] = []
    
    var integrated: [Integrated] = []
    
    var scheduleVC = ScheduleViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = changeDateFormat(selectedDate: selectedDate) // FSCal에서 선택된 날짜를 변수에 저장하고 텍스트로 지정
        listView.dataSource = self
        listView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let schedules = Schedule.shared.schedules
        let groupSchedules = GroupSche.shared3.groupSche
        
        for i in 0..<schedules.count {
            var integratedInstance = Integrated(originKey: schedules[i].originKey, groupOriginKey: "", name: schedules[i].name, userId: schedules[i].userId, startAt: schedules[i].startAt, endAt: schedules[i].endAt, memo: schedules[i].memo, allDayToggle: schedules[i].allDayToggle, color: schedules[i].color)
            integrated.append(integratedInstance)
        }
        
        for i in 0..<groupSchedules.count {
            var integratedInstance = Integrated(originKey: groupSchedules[i].originKey, groupOriginKey: groupSchedules[i].groupOriginKey, name: groupSchedules[i].name, userId: "", startAt: groupSchedules[i].startAt, endAt: groupSchedules[i].endAt, memo: groupSchedules[i].memo, allDayToggle: groupSchedules[i].allDayToggle, color: groupSchedules[i].color)
            integrated.append(integratedInstance)
        }
        
        integrated = integrated.filter { schedule in
            return schedule.startAt.contains(selectedDate)
        }
        
        listView.reloadData()
    }
    
    func changeDateFormat(selectedDate: String) -> String{
        var changeDate: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 (E)"
        changeDate = dateFormatter.string(from: selectDate!)
        
        return changeDate
    }
}

extension DetailViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // datasource
        return integrated.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // datasource
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        let schedule = integrated[indexPath.item]
    
        cell.nameLabel.text = schedule.name
        
        if schedule.allDayToggle == "true" {
            cell.startLabel.text = "all Day"
            cell.endLabel.text = ""
            cell.minusLabel.text = ""
        } else {
            cell.startLabel.text = String(schedule.startAt.split(separator: "T")[1])
            cell.endLabel.text = String(schedule.endAt.split(separator: "T")[1])
        }
        cell.cellOriginKey = schedule.originKey
        cell.cellGroupOriginKey = schedule.groupOriginKey
        
        if cell.cellGroupOriginKey != "" {
            cell.colorMarker.backgroundColor = UIColor(hexString: "ffffff")
            cell.backgroundColor = UIColor(hexString: "ebf0ff")
//            cell.layer.borderWidth = 0.7
            cell.layer.cornerRadius = 10
        }
        else {
            cell.colorMarker.backgroundColor = UIColor(hexString: String(schedule.color.dropFirst()))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = listView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        let schedule = integrated[indexPath.item]
        cell.cellOriginKey = schedule.originKey
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
        vc.detailVC = self
        vc.scheduleVC = scheduleVC
        vc.groupOriginKey = schedule.groupOriginKey
        
        
        present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 90)
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

