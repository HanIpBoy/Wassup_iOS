//
//  AddViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit
import SnapKit
import Then

class WriteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var allDayToggle: UISwitch!
    
    
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var memoTextField: UITextField!
    
    
    
    
    
    var originKey: String = ""
    var name: String = ""
    var startDateString: String = ""
    var endDateString: String = ""
    var memo: String = ""
    
    
    var flag: Bool = false
    
    private var scheduleMap: [String: Any] = [ // 인증 후에 이 뷰컨에 저장할 hashMap
        "name": "",
        "startAt" : "",
        "endAt" : "",
        "userId" : "",
        "memo": "",
        "notification": 1,
        "allDayToggle": ""
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("flag \(flag)")
        initView()
    }
    
    private func initView() {
        verticalStackView.layer.cornerRadius = 10
        
        saveButton.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 10
        
        endDatePicker.date = startDatePicker.date + 600
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = name
        if flag {
            allDayToggle.isOn = true
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
        }
        if titleTextField.text == "" {
            deleteButton.isHidden = true
        } else {
            startDatePicker.date = makeStringDate(dateString: startDateString)
            endDatePicker.date = makeStringDate(dateString: endDateString)
        }
        memoTextField.text = memo
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func allDayMode(_ sender: UISwitch) {
        if allDayToggle.isOn {
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
            flag = !flag
        } else {
            startDatePicker.datePickerMode = .dateAndTime
            endDatePicker.datePickerMode = .dateAndTime
            flag = !flag
        }
    }
    
    
    
    @IBAction func selectStartDate(_ sender: UIDatePicker) {
        if flag {
            endDatePicker.date = sender.date
        }
    }
    
    @IBAction func selectEndDate(_ sender: UIDatePicker) {
        if flag {
            startDatePicker.date = sender.date
        } else {
            if endDatePicker.date <= startDatePicker.date {
                // endDatePicker의 날짜가 startDatePicker의 날짜보다 앞서는 경우
                showToast(message: "종료 날짜는 시작 날짜보다 앞설 수 없습니다.")
                endDatePicker.date = startDatePicker.date + 600
            } else {
//                print(">>> success")
            }
        }
    }
    
    
    @IBAction func saveSchedule(_ sender: UIButton) { // 일정 저장
        scheduleMap["name"] = titleTextField.text
        scheduleMap["startAt"] = makeDateString(date: startDatePicker.date)
        scheduleMap["endAt"] = makeDateString(date: endDatePicker.date)
        scheduleMap["memo"] = memoTextField.text
        scheduleMap["allDayToggle"] = String(flag)
        scheduleMap["userId"] = UserDefaults.standard.string(forKey: "userId")
        let server = Server()
        server.createSchedule(requestURL: "schedule", requestData: scheduleMap, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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

                            Schedule.shared.updateScheduleData(data: scheduleData)
                        }
                    }
                    
                }
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func deleteSchedule(_ sender: UIButton) { // 일정 삭제
        
    }
    
    
    
    
    
    
    @IBAction func closeWrite(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension WriteViewController {
    func makeDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func makeStringDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm"
        let date = dateFormatter.date(from: dateString)
        return date!
        
    }
    
    func showToast(message: String) {
        // Toast 메시지를 띄울 반투명 Label의 너비를 조정하고
        let width = CGFloat(message.count*15)
        
        // Label 생성
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (width/2), y: self.view.frame.size.height-100, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}




