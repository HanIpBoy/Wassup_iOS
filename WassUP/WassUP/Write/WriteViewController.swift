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
    
    var flag: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    private func initView() {
        verticalStackView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
   
    
    
    
    
    
    @IBAction func allDayMode(_ sender: UISwitch) {
        if allDayToggle.isOn {
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
        } else {
            startDatePicker.datePickerMode = .dateAndTime
            endDatePicker.datePickerMode = .dateAndTime
        }
    }
    
    
    
    @IBAction func closeWrite(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

