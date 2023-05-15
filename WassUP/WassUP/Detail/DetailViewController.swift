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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = changeDateFormat(selectedDate: selectedDate) // FSCal에서 선택된 날짜를 변수에 저장하고 텍스트로 지정
        print("Detail_selectedDate : \(selectedDate)")
        
        filteredSchedules = Schedule.shared.schedules.filter { schedule in
            return schedule.startAt.contains(selectedDate)
        }
        
        print("1 : \(filteredSchedules)")
        print(filteredSchedules.count)
        
        listView.dataSource = self
        listView.delegate = self

        
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
        return filteredSchedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // datasource
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        let schedule = filteredSchedules[indexPath.item]
    
        cell.nameLabel.text = schedule.name
        
        if schedule.allDayToggle == "true" {
            cell.startLabel.text = "all Day"
            cell.endLabel.text = ""
            cell.minusLabel.text = ""
            print(">>>> enter")
        } else {
            cell.startLabel.text = String(schedule.startAt.split(separator: "-")[3])
            cell.endLabel.text = String(schedule.endAt.split(separator: "-")[3])
        }
        cell.cellOriginKey = schedule.originKey
        
        print(cell.cellOriginKey)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: listView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = listView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        let schedule = filteredSchedules[indexPath.item]
        cell.cellOriginKey = schedule.originKey
        
        print(cell.cellOriginKey)
        
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
        
        
        present(vc, animated: true)
        
    }
    
    
}



