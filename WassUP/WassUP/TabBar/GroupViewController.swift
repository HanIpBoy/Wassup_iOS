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
        super.viewWillAppear(true)
        Group.shared2.groups = []
        print("3 : \(Group.shared2.groups)")
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
                            print(">>>: \(Group.shared2.groups)")
                        }
                    }
                    DispatchQueue.main.async {
                        self.groupListView.reloadData() // 데이터 업데이트 후 UICollectionView 다시 로드
                    }
                }
            }
        }
        print(">>>>: \(Group.shared2.groups)")
    }

    
    func initView() {
        myView.layer.cornerRadius = 20
        groupListView.layer.cornerRadius = 20
    }

}

extension GroupViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Group.shared2.groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupListCollectionViewCell", for: indexPath) as! GroupListCollectionViewCell
        print("enter cell")
        let group = Group.shared2.groups[indexPath.item]
        print("group : \(group)")
        cell.nameLabel.text = group.groupName
        cell.descriptionLabel.text = group.description
        cell.numberLabel.text = "👥 " + String(group.numOfUsers)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: groupListView.bounds.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = GroupTimeTableViewController()
        
//        present(vc, animated: true)
    }
    
    
    
}
