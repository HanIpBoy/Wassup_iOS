//
//  LoginViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/03/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!
    
    var userEmail:String = ""
    var userPassword:String = ""
    
    let defaulfEmail:String = "1234"
    let defaultPassword:String = "1234"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myViewStyle() // innerView의 스타일 지정
        hideKeyboard() // dismissKeyboard 사용
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    func myViewStyle() {
        myView.layer.cornerRadius = 20
        
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = UIColor(hexString: "0040ff")
        loginButton.tintColor = UIColor(hexString: "0040ff")
        
        signinButton.layer.cornerRadius = 10
        signinButton.tintColor = UIColor(hexString: "000000")
        signinButton.backgroundColor = UIColor(hexString: "000000")
        
    }
    
    @IBAction func goLogin(_ sender: UIButton) {
        userEmail = emailTextField.text!
        userPassword = passwordTextField.text!
        
        let server = Server()
        server.signIn(requestURL: "auth/signin", requestBody: ["userId": userEmail, "password": userPassword]){ (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let json = jsonObject as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    for dataEntry in dataArray {
                        let token = dataEntry["token"] as? String ?? ""
                        UserDefaults.standard.set(token, forKey: "token")
                        print("1번")
                    }
                }
            }
            if UserDefaults.standard.object(forKey: "token") != nil {
                print("2번")
                UserDefaults.standard.set(self.userEmail, forKey: "userId")
                UserDefaults.standard.set(self.userPassword, forKey: "password")
//                self.showToast(message: "로그인 성공")
                
            } else {
                print("3번")
//                self.showToast(message: "올바른 로그인이 아닙니다.")
            }
            
            DispatchQueue.main.async {
                print("4")
                if UserDefaults.standard.object(forKey: "token") != nil {// Home으로 이동하기!
                    print("5")
                    let vcName = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                    vcName?.modalPresentationStyle = .fullScreen
                    vcName?.modalTransitionStyle = .crossDissolve
                    self.present(vcName!, animated: true, completion: nil)
                }
            }
            
            
            
        }
    }
    
    @IBAction func goSignIn(_ sender: UIButton) {
        // SignIn 스토리 보드로 이동하는 코드 삽입
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        guard let signInVC = storyboard.instantiateViewController(withIdentifier: "SignIn") as? SignInViewController else {return}
        present(signInVC, animated: true, completion: nil)
    }
    
}

extension LoginViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    
    convenience init(hexString: String) {
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
}

extension LoginViewController {
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


