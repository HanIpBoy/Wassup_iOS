//
//  GroupSche.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/18.
//

import Foundation
class GroupSche {
    static let shared3 = GroupSche()
    var groupSche : [Format] = []
    
    private init() {}
    
    struct Format {
        var originKey: String
        var groupOriginKey : String
        var name: String
        var startAt: String
        var endAt: String
        var memo: String
        var allDayToggle: String
        var color : String
        
    }
    
    func updateGroupScheData(data: Format) {
        groupSche.append(data)
    }
    
    func findAndUpdateScheduleData(data: Format) {
        if let index = GroupSche.shared3.groupSche.firstIndex(where: { $0.originKey == data.originKey }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            groupSche[index] = data
        }
    }
    func deleteScheduleData(data: Format) {
        if let index = GroupSche.shared3.groupSche.firstIndex(where: { $0.originKey == data.originKey }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            groupSche.remove(at: index)
        }
    }
}
