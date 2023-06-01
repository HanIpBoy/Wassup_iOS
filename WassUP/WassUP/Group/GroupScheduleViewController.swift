//
//  GroupScheduleViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/18.
//

import UIKit

class GroupScheduleViewController: UIViewController { // 그룹 일정을 확인 하는 뷰

    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var groupScheduleListView: UICollectionView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var deleteGroupButton: UIButton!
    @IBOutlet weak var createGroupScheduleButton: UIButton!
    @IBOutlet weak var updateGroupButton: UIButton!
    
    var integrated: [Integrated] = []

    var groupName: String = ""
    var groupDescription: String = ""
    var groupOriginKey: String = ""
    var leaderId: String = ""
    
    var groupVC: GroupViewController!
    var groupTimeTableVC: GroupTimeTableViewController!
    
    let deleteConfirmAlert = UIAlertController(title: "그룹 삭제", message: "", preferredStyle: .alert)

    private var updateMap: [String: Any] = [ // 인증 후에 이 뷰컨에 저장할 hashMap
        "originKey" : "",
        "groupName" : "",
        "leaderId": "",
        "description" : ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        groupScheduleListView.delegate = self
        groupScheduleListView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GroupSche.shared3.groupSche = []
        let server = Server()
        server.getAllData(requestURL: "group/schedule/\(groupOriginKey)", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                            let groupOriginKey = dataEntry["groupOriginKey"] as? String ?? ""
                            let name = dataEntry["name"] as? String ?? ""
                            let startAt = dataEntry["startAt"] as? String ?? ""
                            let endAt = dataEntry["endAt"] as? String ?? ""
                            let memo = dataEntry["memo"] as? String ?? ""
                            let allDayToggle = dataEntry["allDayToggle"] as? String ?? ""
                            let color = dataEntry["color"] as? String ?? ""

                            let groupScheData = GroupSche.Format(
                                originKey: originKey,
                                groupOriginKey: groupOriginKey,
                                name: name,
                                startAt: startAt,
                                endAt: endAt,
                                memo: memo,
                                allDayToggle: allDayToggle,
                                color : color
                            )
                            
                            GroupSche.shared3.updateGroupScheData(data: groupScheData)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.groupScheduleListView.reloadData() // 데이터 업데이트 후 UICollectionView 다시 로드
                    }
                }
            }
        }
    }

    
    private func initView() {
        myView.layer.cornerRadius = 20
        
        groupScheduleListView.layer.cornerRadius = 20
        groupNameLabel.text = groupName
        groupDescriptionLabel.text = groupDescription
        
        if leaderId != UserDefaults.standard.string(forKey: "userId") {
            deleteGroupButton.isHidden = true
            createGroupScheduleButton.isHidden = true
            updateGroupButton.isHidden = true
        }
        else {
            deleteGroupButton.isHidden = false
            createGroupScheduleButton.isHidden = false
            updateGroupButton.isHidden = false
        }
    }
    
    @IBAction func createGroupScheduleButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "WriteGroupSchedule", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WriteGroupSchedule") as! WriteGroupScheduleViewController
        vc.groupOriginKey = groupOriginKey
        vc.listVC = self
        vc.groupName = groupName
        vc.groupTimeTableVC = groupTimeTableVC

        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func updateGroupButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GroupCreate", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupCreateViewController") as? GroupCreateViewController else {return}
        
        vc.groupName = groupNameLabel.text
        vc.groupDescription = groupDescriptionLabel.text
        vc.groupOriginKey = groupOriginKey
        vc.groupUsersEnable = false
        vc.groupVC = groupVC
        vc.groupTimeTableVC = groupTimeTableVC
        vc.groupScheduleVC = self


        
        present(vc, animated: true, completion: nil)    
    }
    @IBAction func deleteGroupButtonTapped(_ sender: Any) {
        self.deleteConfirmAlert.message = "\(self.groupName) 그룹을 삭제하시겠습니까?"
        self.present(self.deleteConfirmAlert, animated: true, completion: nil)
        deleteConfirmAlert.addAction(UIAlertAction(title: "삭제", style: .destructive) { action in
            let server = Server()
            let groupOriginKey = self.groupOriginKey
            server.deleteData(requestURL: "group/\(groupOriginKey)", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                                let leaderId = dataEntry["leaderId"] as? String ?? ""
                                let groupUsers = dataEntry["groupUsers"] as? [String] ?? []
                                let groupData = Group.Format(
                                    originKey: originKey,
                                    groupName: groupName,
                                    description: description,
                                    numOfUsers: numOfUsers,
                                    leaderId: leaderId,
                                    groupUsers: groupUsers
                                    
                                )
                                Group.shared2.deleteGroupData(data: groupData)
                            }
                        }
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
        })
        deleteConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
            self.dismiss(animated: true)
        })
    }
    
}

extension GroupScheduleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let groupSches = GroupSche.shared3.groupSche
        return groupSches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupScheduleCollectionViewCell", for: indexPath) as! GroupScheduleCollectionViewCell
        let groupSches = GroupSche.shared3.groupSche[indexPath.item]
        cell.nameLabel.text = groupSches.name
        cell.startDateLabel.text = formatDateTime(groupSches.startAt)
        cell.endDateLabel.text = formatDateTime(groupSches.endAt)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: groupScheduleListView.bounds.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupScheduleCollectionViewCell", for: indexPath) as! GroupScheduleCollectionViewCell
        
        let schedule = GroupSche.shared3.groupSche[indexPath.item]
        let storyBoard = UIStoryboard(name: "WriteGroupSchedule", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "WriteGroupSchedule") as! WriteGroupScheduleViewController

        vc.name = schedule.name
        if schedule.allDayToggle == "true" {
            vc.flag = true
        } else {
            vc.flag = false
        }
        vc.startDateString = schedule.startAt
        vc.endDateString = schedule.endAt
        vc.memo = schedule.memo
        vc.color = String(schedule.color.dropFirst())
        vc.originKey = schedule.originKey
        vc.groupOriginKey = schedule.groupOriginKey
        vc.groupName = groupName
        vc.listVC = self
        vc.groupTimeTableVC = groupTimeTableVC
        present(vc, animated: true)
    }
}

extension GroupScheduleViewController {
    
    func formatDateTime(_ dateTime: String) -> String {
        let components = dateTime.split(separator: "T")
        let dateComponents = components[0].split(separator: "-")
        let timeComponents = components[1].split(separator: ":")
        
        let formattedDateTime = "\(dateComponents[1]).\(dateComponents[2]) \(timeComponents[0]):\(timeComponents[1])"
        return formattedDateTime
    }
}
