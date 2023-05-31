//
//  Group.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/16.
//

import Foundation
class Group {
    static let shared2 = Group()
    var groups : [Format] = []
    
    private init() {}
    
    struct Format {
        var originKey: String
        var groupName: String
        var description: String
        var numOfUsers: Int
        var leaderId: String
        var groupUsers: [String]
    }
    
    func updateGroupData(data: Format) {
        groups.append(data)
    }
    
    func deleteGroupData(data: Format) {
        if let index = Group.shared2.groups.firstIndex(where: { $0.originKey == data.originKey }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            groups.remove(at: index)
        }
    }
}
