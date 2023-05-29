//
//  GroupCreateViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/30.
//

import UIKit

class GroupCreateViewController: UIViewController {
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var searchUserTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchUserView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var addUserButton: UIButton!
    
    @IBOutlet weak var groupUserBtn1: UIButton!
    @IBOutlet weak var groupUserBtn2: UIButton!
    @IBOutlet weak var groupUserBtn3: UIButton!
    @IBOutlet weak var groupUserBtn4: UIButton!
    @IBOutlet weak var groupUserBtn5: UIButton!
    @IBOutlet weak var groupUserBtn6: UIButton!
    @IBOutlet weak var groupUserBtn7: UIButton!
    @IBOutlet weak var groupUserBtn8: UIButton!
    @IBOutlet weak var groupUserBtn9: UIButton!
    @IBOutlet weak var groupUserBtn10: UIButton!
    
    
    var userMap : [String:String] = [
        "userId" : "",
        "userName" : ""
    ]
    
    var groupMap : [String : Any] = [
        "groupName" : "",
        "description" : "",
        "groupUsers" : []
    ]
    
    
    var groupUsers : [String] = []
    var groupUserNames : [String] = []
    
    var buttonIndex = 1
    var buttons: [UIButton] = []
    
    
    
    var groupVC = GroupViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        
    }
    
    @IBAction func searchUser(_ sender: UIButton) {
        if searchUserTextField.text != "" {
            let server = Server()
            server.getAllData(requestURL: "user/search/\(searchUserTextField.text ?? "ingjwjw@naver.com")", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
                if let response = response as? HTTPURLResponse{ // response는 URLResponse 타입이야.
                    if response.statusCode == 400 {
//                        print("Error: \(response)")
                        DispatchQueue.main.async { [self] in
                            searchUserTextField.text = ""
                            searchUserTextField.placeholder = "유저를 찾을 수 없습니다."
                        }
                        return
                    }
                }
                
                if let data = data {
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                       let json = jsonObject as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]] {
                        for dataEntry in dataArray {
                            if let userId = dataEntry["userId"] as? String {
                                let userName = dataEntry["userName"] as? String ?? ""
                                
                                self.userMap["userId"] = userId
                                self.userMap["userName"] = userName
                            }
                        }
                        
                        DispatchQueue.main.async { [self] in
                            searchUserView.isHidden = false
                            if groupUsers.contains(userMap["userId"]!) {
                                addUserButton.isHidden = true
                            } else {
                                addUserButton.isHidden = false
                            }
                            userNameLabel.text = userMap["userName"]
                            userIdLabel.text = userMap["userId"]
                        }
                    }
                }
            }
        } else {
            searchUserTextField.placeholder = "이메일을 입력해주세요!"
        }
        
    }
    
    @IBAction func addUserTapped(_ sender: UIButton) {
        groupUsers.append(userMap["userId"] ?? "")
        groupUserNames.append(String(userMap["userName"]!.dropFirst()))
        
        for i in 1..<groupUserNames.count {
            buttons[i].isHidden = false
            buttons[i].setTitle(groupUserNames[i], for: .normal)
            buttons[i].layer.cornerRadius = 15
        }
        searchUserView.isHidden = true
        searchUserTextField.text = ""
    }
    
    
    
    @IBAction func deleteGroupUsers(_ sender: UIButton) {
        groupUserNames.remove(at: sender.tag)
        groupUsers.remove(at: sender.tag)
        
        sender.isHidden = true
        
        for i in 1..<groupUserNames.count {
            buttons[i].isHidden = false
            buttons[i].setTitle(groupUserNames[i], for: .normal)
            buttons[i].layer.cornerRadius = 15
        }
        buttons[groupUserNames.count].isHidden = true
        
        print(groupUsers)

    }
    
    @IBAction func saveNewGroup(_ sender: UIButton) {
        groupMap["groupName"] = groupNameTextField.text ?? "이름 없음"
        groupMap["description"] = memoTextField.text ?? ""
        groupMap["groupUsers"] = groupUsers
        
        let server = Server()
        server.postDataToServer(requestURL: "group/create", requestData: groupMap, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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

                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.groupVC.viewWillAppear(true)
                    }
                    
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
}

extension GroupCreateViewController {
    private func initView() {
        myView.layer.cornerRadius = 10
        
        searchButton.layer.borderWidth = 0.5
        searchButton.layer.cornerRadius = 10
        searchButton.layer.borderColor = CGColor(red: 0, green: 64/255, blue: 1, alpha: 1)
        
        searchUserView.isHidden = true
        searchUserView.layer.cornerRadius = 10
        searchUserView.layer.borderColor = UIColor.lightGray.cgColor
        searchUserView.layer.borderWidth = 0.5
        searchUserView.backgroundColor = UIColor.white
        
        buttons.append(groupUserBtn1)
        buttons.append(groupUserBtn2)
        buttons.append(groupUserBtn3)
        buttons.append(groupUserBtn4)
        buttons.append(groupUserBtn5)
        buttons.append(groupUserBtn6)
        buttons.append(groupUserBtn7)
        buttons.append(groupUserBtn8)
        buttons.append(groupUserBtn9)
        buttons.append(groupUserBtn10)

        for i in 1..<buttons.count {
            buttons[i].isHidden = true
        }
        let myName = UserDefaults.standard.string(forKey: "userName")! // print의 결과 : Optinal("유영재")
        let newMyName = String(myName.dropFirst())
        
        groupUserBtn1.setTitle(newMyName, for: .normal)
        groupUserBtn1.layer.cornerRadius = 15
        groupUsers.append(UserDefaults.standard.string(forKey: "userId")!)
        groupUserNames.append(UserDefaults.standard.string(forKey: "userName")!)
    }
}
