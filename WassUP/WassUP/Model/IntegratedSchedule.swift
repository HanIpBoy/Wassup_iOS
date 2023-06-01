//
//  Integrated.swift
//  WassUP
//
//  Created by 유영재 on 2023/05/31.
//

import Foundation

class IntegratedSchedule {
    static let shared4 = IntegratedSchedule()
    var integrated : [Format] = []
    
    private init() {}
    
    struct Format {
        var originKey: String
        var groupOriginKey : String
        var name: String
        var userId: String
        var startAt: String
        var endAt: String
        var memo: String
        var allDayToggle: String
        var color : String
    }
    
    func updateIntegrated(data: Format) {
        integrated.append(data)
    }
}
