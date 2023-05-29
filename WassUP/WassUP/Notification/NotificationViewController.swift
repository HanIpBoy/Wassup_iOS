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
    
    //    private var notificationArr: [Notification]!
    private var responseNotiData :[String: String] = [
        "originKey" : "",
        "groupOriginKey" : ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        notificationCollectionView.dataSource = self
        notificationCollectionView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Notification.sharedNoti.notifications = []
        //        notificationArr.removeAll()
        
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
                            print("notification data : \(notificationData)")
                            print("notification shard : \(Notification.sharedNoti.notifications)")
                            
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
        let index = sender.tag
        
        responseNotiData["originKey"] = Notification.sharedNoti.notifications[index].originKey
        responseNotiData["groupOriginKey"] = Notification.sharedNoti.notifications[index].groupOriginKey
        let originKey = responseNotiData["originKey"] ?? ""
        let cellCount = Notification.sharedNoti.notifications.count

        let server = Server()
        let token = UserDefaults.standard.string(forKey: "token")!
        server.postDataToServer(requestURL: "group/invitation/accept", requestData: responseNotiData, token: token) { _, _, _ in
            server.deleteData(requestURL: "user/notification/\(originKey)", token: token) { _, _, _ in
                print("token : \(token)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        responseNotiData["originKey"] = Notification.sharedNoti.notifications[index].originKey
        let originKey = responseNotiData["originKey"] ?? ""
        let cellCount = Notification.sharedNoti.notifications.count
        
        let server = Server()
        server.deleteData(requestURL: "user/notification/\(originKey)", token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
            print("enter")
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
    }
    
    
}

extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let notifications = Notification.sharedNoti.notifications
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notifications = Notification.sharedNoti.notifications[indexPath.item]
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
        
        cell.notificationVC = self
        
        cell.yesButton.tag = indexPath.item // 버튼에 해당 셀의 인덱스를 태그로 설정
        cell.yesButton.addTarget(self, action: #selector(yesButtonTapped(_:)), for: .touchUpInside)
        
        cell.noButton.tag = indexPath.item // 버튼에 해당 셀의 인덱스를 태그로 설정
        cell.noButton.addTarget(self, action: #selector(noButtonTapped(_:)), for: .touchUpInside)
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // layout
        return CGSize(width: notificationCollectionView.bounds.width, height: 150)
    }
    
}
    
