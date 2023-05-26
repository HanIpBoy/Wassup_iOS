//
//  NotificationViewController.swift
//  WassUP
//
//  Created by 유영재 on 2023/05/25.
//

import UIKit


class NotificationViewController: UIViewController {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var notificationCollectionView: UICollectionView!
    
    var originKey: String!
    var groupOriginKey: String!
    
    private var notificationMap: [String: String] = [ // 인증 후에 이 뷰컨에 저장할 hashMap
        "originKey": "",
        "groupOriginKey" : ""
    ]
    private var notificationMapArr: [[String: String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        notificationCollectionView.dataSource = self
        notificationCollectionView.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Notification.sharedNoti.notification = []
        notificationMap.removeAll()
//        notificationMapArr.removeAll()
        let server = Server()
        server.getAllData(requestURL: "user/notification/unread", token: UserDefaults.standard.string(forKey: "token")!) { (data, response, error) in
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
                            let userId = dataEntry["userId"] as? String ?? ""
                            let title = dataEntry["title"] as? String ?? ""
                            let message = dataEntry["message"] as? String ?? ""
                            let groupOriginKey = dataEntry["groupOriginKey"] as? String ?? ""
                            
                            let notificationData = Notification.Format(
                                originKey: originKey,
                                userId: userId,
                                title: title,
                                message: message,
                                groupOriginKey: groupOriginKey
                            )
                            
                            Notification.sharedNoti.updateNotificationData(data: notificationData)
                            self.notificationMap["originKey"] = notificationData.originKey
                            self.notificationMap["groupOriginKey"] = notificationData.groupOriginKey
//                            self.notificationMapArr.append(self.notificationMap)
                        }
                    }
                    DispatchQueue.main.async {
                        
                        self.notificationCollectionView.reloadData()
                        self.notificationCollectionView.layoutIfNeeded()

                    }
                }
            }
        }
    }
    private func initView() {
        outerView.layer.cornerRadius = 20
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? NotificationCell {
            for i in 0..<Notification.sharedNoti.notification.count {
                if cell.messageLabel.text == Notification.sharedNoti.notification[i].message{
                    self.originKey = Notification.sharedNoti.notification[i].originKey
                    print("originKey is ~ \(self.originKey)")
                    self.groupOriginKey = Notification.sharedNoti.notification[i].groupOriginKey
                }
            }
        }
        let server = Server()
        let server2 = Server()
        
        server.postDataToServer(requestURL: "group/invitation/accept", requestData: notificationMap, token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
            print("originKey : \(self.originKey)")
            server2.DeleteData(requestURL: "user/notification/\(self.originKey)", token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
                print("enter")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    @IBAction func noButtonTapped(_ sender: UIButton) {
//        if let cell = sender.superview?.superview as? NotificationCell {
//            for i in 0..<notificationMapArr.count {
//                print("\(Notification.sharedNoti.notification)")
//                if cell.messageLabel.text == Notification.sharedNoti.notification[i].message{
//                    if Notification.sharedNoti.notification[i]
//                        .originKey == notificationMapArr["originKey"].val
//                    self.originKey = Notification.sharedNoti.notification[i]
//                        .originKey
//                    print("originKey 2개 \(self.originKey) \(Notification.sharedNoti.notification[i].originKey)")
//                }
//            }
//        }
//        let server = Server()
//        server.DeleteData(requestURL: "user/notification/\(self.originKey)", token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
//            return
//        }
//
    }
}

extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let notifications = Notification.sharedNoti.notification
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notifications = Notification.sharedNoti.notification[indexPath.item]
        if notifications.title == "그룹 초대" {
            cell.yesButton.isHidden = false
            cell.noButton.isHidden = false
        }
        else {
            cell.yesButton.isHidden = true
            cell.noButton.isHidden = true
        }
        cell.messageLabel.preferredMaxLayoutWidth = collectionView.bounds.width
        cell.messageLabel.text = notifications.message
        cell.messageLabel.numberOfLines = 0
        cell.layoutIfNeeded()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: notificationCollectionView.bounds.width, height: 150)
    }
    
    
}
