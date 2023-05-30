//
//  GroupViewController.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/16.
//

import UIKit

class GroupViewController: UIViewController {

    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var groupListView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupListView.delegate = self
        groupListView.dataSource = self
        
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Group.shared2.groups = []
        let server = Server()
        server.getAllData(requestURL: "group", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                            
                            Group.shared2.updateGroupData(data: groupData)
                        }
                    }
                    DispatchQueue.main.async {
                        self.groupListView.reloadData() // 데이터 업데이트 후 UICollectionView 다시 로드
                    }
                }
            }
        }
    }

    
    func initView() {
        myView.layer.cornerRadius = 20
        groupListView.layer.cornerRadius = 20
    }
    
    @IBAction func groupCreate(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupCreate", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupCreateViewController") as? GroupCreateViewController else { return
        }
        
        vc.groupVC = self
        present(vc, animated: true)
    }
    
    
    
    func getStartAndEndOfWeek() -> (String, String) {
        let calendar = Calendar.current
        let today = Date()

        // 현재 날짜가 속한 주의 시작 날짜를 계산합니다.
        var startOfWeek: Date? = nil
        var interval: TimeInterval = 0
        calendar.dateInterval(of: .weekOfYear, start: &startOfWeek!, interval: &interval, for: today) // Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value

        // 현재 날짜가 속한 주의 마지막 날짜를 계산합니다.
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek!)

        // 날짜 형식을 원하는 형태로 변환합니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd"

        // 주의 시작 날짜와 마지막 날짜를 문자열로 변환합니다.
        let startOfWeekString = dateFormatter.string(from: startOfWeek!)
        let endOfWeekString = dateFormatter.string(from: endOfWeek!)

        return (startOfWeekString, endOfWeekString)
    }

}

extension GroupViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Group.shared2.groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupListCollectionViewCell", for: indexPath) as! GroupListCollectionViewCell
        let group = Group.shared2.groups[indexPath.item]
        cell.nameLabel.text = group.groupName
        cell.descriptionLabel.text = group.description
        cell.numberLabel.text = "👥 " + String(group.numOfUsers)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: groupListView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupTimeTable", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GroupTimeTableViewController") as? GroupTimeTableViewController else { return }
        let group = Group.shared2.groups[indexPath.item]
        var dict: [String : Any] = ["groupUsers" : group.groupUsers]
        vc.groupName = group.groupName
        vc.groupOriginKey = group.originKey
        vc.groupUsers = dict
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
}
