//
//  AddViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/27.
//

import UIKit

class WriteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var allDayToggle: UISwitch!
    
    
    @IBOutlet weak var colorButtonView: UIView!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var memoTextField: UITextField!
    
    var scheduleVC = ScheduleViewController()
    var detailVC = DetailViewController()
    var colorPickerView: UIPickerView!

    var originKey: String = ""
    var name: String = ""
    var startDateString: String = ""
    var endDateString: String = ""
    var memo: String = ""
    var color: String = ""
    
    var flag: Bool = false
    
    private var scheduleMap: [String: Any] = [ // 인증 후에 이 뷰컨에 저장할 hashMap
        "name": "",
        "startAt" : "",
        "endAt" : "",
        "userId" : "",
        "memo": "",
        "allDayToggle": "",
        "color" : ""
    ]
    
    struct ColorOption {
        let text: String
        let color: String
    }
        
    let colors: [ColorOption] = [
        ColorOption(text: "Red", color: "#E45C5C"),
        ColorOption(text: "Orange", color: "#F37C39"),
        ColorOption(text: "Yellow", color: "#F2DD1B"),
        ColorOption(text: "Green", color: "#2CC91E"),
        ColorOption(text: "Blue", color: "#474DDF"),
        ColorOption(text: "Navy", color: "#311E7B"),
        ColorOption(text: "Purple", color: "#BO4BD3"),
        ColorOption(text: "Pink", color: "#FF4BE2"),
        ColorOption(text: "Black", color: "#000000"),
        ColorOption(text: "Brown", color: "#7B4C15")
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
        
        colorButton.addTarget(self, action: #selector(showColorPicker), for: .touchUpInside)
       // colorPickerView 초기화
        colorPickerView = UIPickerView()
       colorPickerView.delegate = self
       colorPickerView.dataSource = self
        colorPickerView.frame = CGRect(x: 25, y: 530, width: memoTextField.bounds.width, height: 200) // 원하는 위치와 크기로 조정
       colorPickerView.layer.cornerRadius = 10
       // colorPickerView 스타일 설정
        colorPickerView.backgroundColor = UIColor(hexString: "f5f5f5")
       colorPickerView.isHidden = true // 초기에 숨김 상태로 설정
        colorButtonView.layer.cornerRadius = 10
        colorButton.tintColor = UIColor(hexString: self.color ?? "000000")
       // colorPickerView를 버튼이 속한 뷰에 추가
       view.addSubview(colorPickerView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first, !colorPickerView.isHidden {
            let touchPoint = touch.location(in: view)
            
            // colorPickerView 외부를 터치한 경우에만 closeColorPicker() 호출
            if !colorPickerView.frame.contains(touchPoint) {
                closeColorPicker()
            }
        }
    }
    
    @objc func showColorPicker() {
        colorPickerView.isHidden = false // colorPickerView 나타내기
    }
        
    func closeColorPicker() {
        colorPickerView.isHidden = true // colorPickerView 닫기
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
        if flag {
            scheduleMap["startAt"] = makeAllDay(date: startDatePicker.date) + "T00:00"
            scheduleMap["endAt"] = makeAllDay(date: endDatePicker.date) + "T23:59"
        } else {
            scheduleMap["startAt"] = makeDateString(date: startDatePicker.date)
            scheduleMap["endAt"] = makeDateString(date: endDatePicker.date)
        }
        scheduleMap["memo"] = memoTextField.text
        scheduleMap["allDayToggle"] = String(flag)
        scheduleMap["userId"] = UserDefaults.standard.string(forKey: "userId")
        scheduleMap["color"] = colorToHexString(colorButton.tintColor)
        let server = Server()
        server.postDataToServer(requestURL: "schedule", requestData: scheduleMap, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                            let color = dataEntry["color"] as? String ?? ""
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
                        }
                    }
                    DispatchQueue.main.async {
                        self.scheduleVC.viewWillAppear(true)
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func deleteSchedule(_ sender: UIButton) { // 일정 삭제
        let server = Server()
        let originKey = self.originKey
        server.deleteData(requestURL: "schedule/\(originKey)", token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
            print("enter")
            DispatchQueue.main.async {
                self.scheduleVC.viewWillAppear(true)
                self.detailVC.viewWillAppear(true)
                self.dismiss(animated: true)

            }
        }
    }

    @IBAction func closeWrite(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension WriteViewController {
    func makeDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func makeStringDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    func makeAllDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
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
    private func colorToHexString(_ color: UIColor) -> String {
        guard let components = color.cgColor.components else {
            return ""
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r) * 255), lroundf(Float(g) * 255), lroundf(Float(b) * 255))
        return hexString
    }
}

extension WriteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // UIPickerViewDataSource 프로토콜 메서드
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 컴포넌트 수 (여기서는 단일 컴포넌트)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count // 컴포넌트 내의 행 수
    }
    
    // UIPickerViewDelegate 프로토콜 메서드
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let option = colors[row]
        
        // 컨테이너 뷰 생성
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        
        // 사각형 뷰 생성
        let colorView = UIView(frame: CGRect(x: 30, y: 0, width: 20, height: 20))
        colorView.backgroundColor = UIColor(hexString: String(option.color.dropFirst()))
        colorView.center.y = containerView.center.y
        colorView.layer.cornerRadius = 10
        
        // 텍스트 레이블 생성
        let label = UILabel(frame: CGRect(x: 60, y: 0, width: 170, height: 40))
        label.text = option.text
        label.textAlignment = .left
        label.center.y = containerView.center.y
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        // 컨테이너 뷰에 사각형 뷰와 텍스트 레이블 추가
        containerView.addSubview(colorView)
        containerView.addSubview(label)
        
        return containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0 // 각 행의 높이 설정
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = colors[row]
        let selectedColor = color.color.dropFirst()
        print(selectedColor)
        // 선택한 색상을 처리하는 로직 추가
        colorButton.tintColor = UIColor(hexString: String(selectedColor))
        
    }
    
    
}




