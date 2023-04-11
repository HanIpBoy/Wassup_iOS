//
//  HomeViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit

class ScheduleViewController: UIViewController {

    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private var calendarDate = Date()
    private var days = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        myViewStyle()
        configureCalendar()
    }
    
    func myViewStyle() {
        myView.layer.cornerRadius = 20
        
        todayButton.tintColor = UIColor(red: 0, green: 64/255, blue: 255/255, alpha: 1)
        todayButton.layer.cornerRadius = 15
        todayButton.layer.masksToBounds = true
    }
    
    private func configureCalendar() {
        self.dateFormatter.dateFormat = "yyyy년 MM월"
        self.today()
    }
    
    private func today() {
        let components = self.calendar.dateComponents([.year, .month], from: Date())
        self.calendarDate = self.calendar.date(from: components) ?? Date()
        self.updateCalendar()
    }
    
    func startDayOfTheWeek() -> Int {
        return self.calendar.component(.weekday, from: self.calendarDate) - 1
    }
    
    func endDate() -> Int {
        return self.calendar.range(of: .day, in: .month, for: self.calendarDate)?.count ?? Int()
    }
    
    func updateTitle() {
        let date = self.dateFormatter.string(from: self.calendarDate)
        self.titleLabel.text = date
    }
    
    func updateDays() {
        self.days.removeAll()
        let startDayOfTheWeek = self.startDayOfTheWeek()
        let totalDays = startDayOfTheWeek + self.endDate()
        
        for day in Int()..<totalDays {
            if day < startDayOfTheWeek {
                self.days.append("")
                continue
            }
            self.days.append("\(day - startDayOfTheWeek + 1)")
        }
        
        self.collectionView.reloadData()
    }
    
    func updateCalendar() {
        self.updateTitle()
        self.updateDays()
    }
    
    func minusMonth() {
        self.calendarDate = self.calendar.date(byAdding: DateComponents(month:-1), to: self.calendarDate) ?? Date()
        self.updateCalendar()
    }
    
    func plusMonth(){
        self.calendarDate = self.calendar.date(byAdding: DateComponents(month:1), to: self.calendarDate) ?? Date()
        self.updateCalendar()
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        self.plusMonth()
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        self.minusMonth()
    }
    

    @IBAction func moveToday(_ sender: UIButton) {
        self.today()
    }
    

}


extension ScheduleViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell else { return CalendarCollectionViewCell() }
        cell.update(day: self.days[indexPath.item])
        
        if indexPath.row % 7 == 0 {
            cell.dayLabel.textColor = .red
        } else if indexPath.row % 7 == 6 {
            cell.dayLabel.textColor = .blue
        } else {
            cell.dayLabel.textColor = .black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.weekStackView.frame.width / 7
        let height = self.collectionView.frame.height / 6.7

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

}

