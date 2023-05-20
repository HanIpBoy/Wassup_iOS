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
    
    var groupName: String = ""
    var groupOriginKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        groupScheduleListView.delegate = self
        groupScheduleListView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("groupOriginKey : \(groupOriginKey)")
        GroupSche.shared3.groupSche = []
        let server = Server()
        server.getAllData(requestURL: "group/schedule/schedules/\(groupOriginKey)", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
//                            print(">>>: \(GroupSche.shared3.groupSche)")
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.groupScheduleListView.reloadData() // 데이터 업데이트 후 UICollectionView 다시 로드
                        print("GroupSche: \(GroupSche.shared3.groupSche)")
                    }
                }
            }
        }
    }

    
    private func initView() {
        myView.layer.cornerRadius = 20
        addTapGesture()
        
        groupScheduleListView.layer.cornerRadius = 20
        
        groupNameLabel.text = groupName
    }

}

extension GroupScheduleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupScheduleCollectionViewCell", for: indexPath) as! GroupScheduleCollectionViewCell
//        let groupSches = GroupSche.shared3.groupSche[indexPath.item]
        cell.nameLabel.text = "groupSches.name"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: groupScheduleListView.bounds.width, height: 50)
    }
    
    
}

extension GroupScheduleViewController {
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: view)
        if !myView.frame.contains(touchLocation) {
            dismiss(animated: true, completion: nil)
        }
    }
}
