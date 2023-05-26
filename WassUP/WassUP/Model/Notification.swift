//
//  Notification.swift
//  WassUP
//
//  Created by 유영재 on 2023/05/25.
//

import Foundation

class Notification {
    static let sharedNoti = Notification()

    var notifications: [Format] = []
    
    private init() {}
    
    struct Format {
        var originKey: String
        var userId: String
        var title: String
        var message: String
        var groupOriginKey: String
    }
    
    func updateNotificationData(data: Format) {
        notifications.append(data)
    }
}


