//
//  SettingViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/11.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func logOut(_ sender: UIButton) {
        
        // 로그아웃하니까 저장했던 사용자의 정보를 지우기
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "password")
        
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.modalTransitionStyle = .crossDissolve
        self.present(vcName!, animated: true, completion: nil)
    }
    
}
