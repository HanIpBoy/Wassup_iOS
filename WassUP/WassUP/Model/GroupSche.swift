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
}
