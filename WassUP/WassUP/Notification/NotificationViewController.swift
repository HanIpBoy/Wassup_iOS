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
    
    @IBOutlet weak var deleteAllButton: UIButton!
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
        addTapGesture()
    }
    
  
    @IBAction func deleteAllButtonTapped(_ sender: Any) {
        let deleteConfirmAlert = UIAlertController(title: "알림 전체 삭제", message: "알림을 모두 삭제 하시겠습니까?", preferredStyle: .alert)
        
        self.present(deleteConfirmAlert, animated: true, completion: nil)
        deleteConfirmAlert.addAction(UIAlertAction(title: "삭제", style: .destructive) { action in
            let server = Server()
            let token = UserDefaults.standard.string(forKey: "token")!
            server.deleteData(requestURL: "user/notification", token: token) { _, _, _ in
                DispatchQueue.main.async {
                    Notification.sharedNoti.notifications.removeAll()
                    self.dismiss(animated: true)

                    self.viewWillAppear(false)
                }
            }
        })
        
        deleteConfirmAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
//            self.dismiss(animated: true)

        })
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
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        let cellCount = Notification.sharedNoti.notifications.count

        let index = cellCount - sender.tag - 1
        print("index >>> \(index)")
        print("sender tag >>> \(sender.tag)")
        print("count >>> \(cellCount)")
        print("response >> \(responseNotiData.count)")
        responseNotiData["originKey"] = Notification.sharedNoti.notifications[index].originKey
        let originKey = responseNotiData["originKey"] ?? ""
        
        let server = Server()
        server.deleteData(requestURL: "user/notification/\(originKey)", token: UserDefaults.standard.string(forKey: "token")!) { _, _, _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}

extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let notifications = Notification.sharedNoti.notifications
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
//        let notifications = Notification.sharedNoti.notifications[indexPath.item]
        var notification = Notification.sharedNoti.notifications
        notification.reverse()
        let reversedNotifications = Array(notification)
        let notifications = reversedNotifications[indexPath.item]
        
        if notifications.title == "그룹 초대" {
            cell.yesButton.isHidden = false
            cell.noButton.isHidden = false
        }
        else {
            cell.yesButton.isHidden = true
            cell.noButton.isHidden = true
        }
        cell.messageLabel.numberOfLines = 0
        cell.messageLabel.text = notifications.message
        cell.messageLabel.numberOfLines = 0
        
        cell.titleLabel.text = notifications.title
        
        cell.notificationVC = self
        
        cell.yesButton.tag = indexPath.item // 버튼에 해당 셀의 인덱스를 태그로 설정
        cell.yesButton.addTarget(self, action: #selector(yesButtonTapped(_:)), for: .touchUpInside)
        
        cell.noButton.tag = indexPath.item // 버튼에 해당 셀의 인덱스를 태그로 설정
        cell.noButton.addTarget(self, action: #selector(noButtonTapped(_:)), for: .touchUpInside)
        
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(noButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height: CGFloat = 110
        return CGSize(width: width, height: height)
    }
}

extension NotificationViewController {
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: view)
        if !outerView.frame.contains(touchLocation) {
            dismiss(animated: true, completion: nil)
        }
    }
}
