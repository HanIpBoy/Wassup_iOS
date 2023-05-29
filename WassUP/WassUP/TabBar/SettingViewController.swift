//
//  SettingViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/11.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var birthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var myView: UIView!
    
    var userMap : [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let server = Server()
        server.getAllData(requestURL: "user/search/\(UserDefaults.standard.string(forKey: "userId") ?? "ingjwjw@naver.com")", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let json = jsonObject as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    for dataEntry in dataArray {
                        if let userId = dataEntry["userId"] as? String {
                            let userName = dataEntry["userName"] as? String ?? ""
                            let birth = dataEntry["birth"] as? String ?? ""
                            self.userMap["userName"] = userName
                            self.userMap["birth"] = birth
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.birthTextField.text = self.userMap["birth"]
                        self.nameTextField.text = self.userMap["userName"]
                    }
                    
                }
            }
        }
    }
        
    @IBAction func logOut(_ sender: UIButton) {
        
        // 로그아웃하니까 저장했던 사용자의 정보를 지우기
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.modalTransitionStyle = .crossDissolve
        self.present(vcName!, animated: true, completion: nil)
    }
    
}

extension SettingViewController {
    private func initView() {
        myView.layer.cornerRadius = 20
        
        logoutButton.tintColor = UIColor.red
        
        emailTextField.text = UserDefaults.standard.string(forKey: "userId")
    }
}
