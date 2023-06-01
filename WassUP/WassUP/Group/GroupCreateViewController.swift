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
    
    @IBOutlet weak var searchUserLabel: UILabel!
    @IBOutlet weak var searchUserStackView: UIStackView!
    @IBOutlet weak var groupUsersView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var addUserButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    var updateMap : [String : Any] = [
        "originKey": "",
        "groupName" : "",
        "description" : "",
        "leaderId" : ""
    ]
    
    var groupName: String!
    var groupDescription: String!
    var groupOriginKey: String!
    var groupUsersEnable: Bool!
    
    var groupUsers : [String] = []
    var groupUserNames : [String] = []
    
    var buttonIndex = 1
    var buttons: [UIButton] = []
    
    var groupVC: GroupViewController!
    var groupScheduleVC: GroupScheduleViewController!
    var groupTimeTableVC: GroupTimeTableViewController!

    let createConfirmAlert = UIAlertController(title: "그룹 생성", message: "", preferredStyle: .alert)
    let updateConfirmAlert = UIAlertController(title: "그룹 정보 수정", message: "", preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        groupNameTextField.text = groupName ?? ""
        memoTextField.text = groupDescription ?? ""
        
        if !groupUsersEnable {
            searchUserStackView.isHidden = true
            searchButton.isHidden = true
            searchUserLabel.isHidden = true
            searchUserTextField.isHidden = true
            titleLabel.text = "그룹 정보 수정"
            
        }
        else {
            searchUserStackView.isHidden = false
            searchButton.isHidden = false
            searchUserLabel.isHidden = false
            searchUserTextField.isHidden = false
            titleLabel.text = "그룹 생성"

        }
        
    }
    
    @IBAction func searchUser(_ sender: UIButton) {
        if searchUserTextField.text != "" {
            let server = Server()
            server.getAllData(requestURL: "user/search/\(searchUserTextField.text ?? "ingjwjw@naver.com")", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
                if let response = response as? HTTPURLResponse{ // response는 URLResponse 타입이야.
                    if response.statusCode == 400 {
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
        

    }
    
    @IBAction func saveNewGroup(_ sender: UIButton) {
        groupMap["groupName"] = groupNameTextField.text ?? "이름 없음"
        groupMap["description"] = memoTextField.text ?? ""
        groupMap["groupUsers"] = groupUsers
        
        updateMap["groupName"] = groupNameTextField.text ?? ""
        updateMap["description"] = memoTextField.text ?? ""
        updateMap["originKey"] = groupOriginKey ?? ""
        updateMap["leaderId"] = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        let server = Server()
        if groupUsersEnable { // true면 생성
            self.createConfirmAlert.message = "\(groupNameTextField.text!) 그룹을 생성하시겠습니까?"
            self.present(self.createConfirmAlert, animated: true, completion: nil)
            
            createConfirmAlert.addAction(UIAlertAction(title: "생성", style: .destructive) { [self] action in
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
                                    let groupName = dataEntry["groupName"] as? String ?? ""
                                    let description = dataEntry["description"] as? String ?? ""
                                    let numOfUsers = dataEntry["numOfUsers"] as? Int ?? 0
                                    let groupUsers = dataEntry["groupUsers"] as? [String] ?? []
                                    let leaderId = dataEntry["leaderId"] as? String ?? ""
                                    
                                    let groupData = Group.Format(
                                        originKey: originKey,
                                        groupName: groupName,
                                        description: description,
                                        numOfUsers: numOfUsers,
                                        leaderId: leaderId,
                                        groupUsers: groupUsers
                                    )
                                    DispatchQueue.main.async {
                                        Group.shared2.updateGroupData(data: groupData)
                                        self.groupVC.viewWillAppear(true)
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            })
            
            createConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
                self.dismiss(animated: true)
            })
            
        }
        
        else { // false면 수정
            self.updateConfirmAlert.message = " \(self.groupName!) 그룹 정보를 수정하시겠습니까?"
            self.present(self.updateConfirmAlert, animated: true, completion: nil)
            
            updateConfirmAlert.addAction(UIAlertAction(title: "수정", style: .destructive) { [self] action in
                server.updateData(requestURL: "group", requestData: updateMap, token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                                    let groupName = dataEntry["groupName"] as? String ?? ""
                                    let description = dataEntry["description"] as? String ?? ""
                                    let numOfUsers = dataEntry["numOfUsers"] as? Int ?? 0
                                    let groupUsers = dataEntry["groupUsers"] as? [String] ?? []
                                    let leaderId = dataEntry["leaderId"] as? String ?? ""
                                    
                                    let groupData = Group.Format(
                                        originKey: originKey,
                                        groupName: groupName,
                                        description: description,
                                        numOfUsers: numOfUsers,
                                        leaderId: leaderId,
                                        groupUsers: groupUsers
                                    )
                                    Group.shared2.findAndUpdateGroupData(data: groupData)

                                    DispatchQueue.main.async {
                                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                        let vcName = storyboard.instantiateViewController(withIdentifier: "TabBar")as? TabBarViewController
                                        
                                        vcName!.selectTab(at: 2)
                                        vcName?.modalPresentationStyle = .fullScreen
                                        vcName?.modalTransitionStyle = .crossDissolve
                                        self.present(vcName!, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            })
            updateConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { [self] action in
                self.dismiss(animated: true, completion: nil)

            })
            
        }
        
        
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
