//
//  SignInViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var phoneAuthButton: UIButton!
    
    @IBOutlet weak var completeSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myViewStyle()
        hideKeyboard()
    }
    
    func myViewStyle() {
        myView.layer.cornerRadius = 10
        phoneAuthButton.layer.cornerRadius = 5
        phoneAuthButton.layer.borderWidth = 0.1
        
        completeSignInButton.layer.cornerRadius = 10
        completeSignInButton.layer.borderWidth = 0.1
//        completeSignInButton.layer.borderColor = UIColor(hexString: "0040ff")
//        completeSignInButton.tintColor = UIColor(hexString: "0040ff")
//        completeSignInButton.backgroundColor = UIColor(hexString: "0040ff")
        
    }
    
    
    @IBAction func makePhoneAuth(_ sender: UIButton) { // 휴대폰 인증
        
    }
    
    @IBAction func backToLogin(_ sender: UIButton) { // 로그인 화면으로 돌아가기
        dismiss(animated: true)
    }
    
    @IBAction func completeSignIn(_ sender: UIButton) {
        // 서버의 DB로 정보를 전송
        
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
}
