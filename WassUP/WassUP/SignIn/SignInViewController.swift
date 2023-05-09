//
//  SignInViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailAuthButton: UIButton!
    
    @IBOutlet weak var numTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var pwdTextField: UITextField!
    
    @IBOutlet weak var birthView: UIView!
    @IBOutlet weak var birthLabel: UILabel!
    
    @IBOutlet weak var completeSignInButton: UIButton!
    
    private var userMap: [String: String] = [ // 인증 후에 이 뷰컨에 저장할 hashMap
        "name": "",
        "email" : "",
        "password" : "",
        "birth" : ""
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myViewStyle()
        hideKeyboard()
    }
    
    func myViewStyle() { // view UI 구성
        myView.layer.cornerRadius = 10
        
        emailAuthButton.layer.borderWidth = 0.5
        emailAuthButton.layer.cornerRadius = 10
        emailAuthButton.layer.borderColor = CGColor(red: 0, green: 64/255, blue: 1, alpha: 1) // 0040ff를 cgcolor 형식으로 지정
        
        checkButton.layer.borderWidth = 0.5
        checkButton.layer.cornerRadius = 10
        checkButton.layer.borderColor = CGColor(red: 0, green: 64/255, blue: 1, alpha: 1)
        
        birthView.layer.cornerRadius = 10
        birthView.layer.borderWidth = 0.5
        birthView.layer.borderColor = CGColor(red: 0.8275, green: 0.8275, blue: 0.8275, alpha: 1.0)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthLabel.text = dateFormatter.string(from: date)
        
        completeSignInButton.layer.cornerRadius = 10
        completeSignInButton.layer.borderWidth = 0.1
        
    }
    
    
    
    @IBAction func emailCheck(_ sender: UIButton) {
        if emailTextField.text == "" {
            showToast(message: "이메일을 다시 한번 확인해 주세요.")
        } else {
            
        }
    }
    
    @IBAction func numCheck(_ sender: UIButton) {
        if numTextField.text == "" { // 입력된 것이 없기에 토스트 메시지 띄우기
            showToast(message: "인증번호를 다시 한번 확인해 주세요.")
        } else { // 서버에 보내야 할 프로토콜
            
            
            userMap["email"] = emailTextField.text!
        }
    }
    
    @IBAction func pwdCheck(_ sender: UITextField) {
        if sender.text != pwdTextField.text {
            showToast(message: "비밀번호가 일치하지 않습니다.")
        } else {
            userMap["password"] = pwdTextField.text
        }
    }
    
    @IBAction func selectBirthDay(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthLabel.text = dateFormatter.string(from: sender.date)
        userMap["birth"] = birthLabel.text
    }
    
    @IBAction func backToLogin(_ sender: UIButton) { // 로그인 화면으로 돌아가기
        dismiss(animated: true)
    }
    
    @IBAction func completeSignIn(_ sender: UIButton) { // 서버의 DB로 정보를 전송
        
        dismiss(animated: true) // 모달 닫기
    }
    
    
}

extension SignInViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showToast(message: String) {
        // Toast 메시지를 띄울 반투명 Label의 너비를 조정하고
        let width = CGFloat(message.count*15)
        
        // Label 생성
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (width/2), y: self.view.frame.size.height-150, width: width, height: 35))
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

