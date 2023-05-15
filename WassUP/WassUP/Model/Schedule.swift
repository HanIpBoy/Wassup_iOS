//
//  Schedule.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/15.
//

import Foundation

class Schedule {
    static let shared = Schedule()
    var keys: [String] = []
//    var schedules: [String: Format] = [:]
    var schedules: [Format] = []

    private init() {}

    struct Format {
        var originKey: String
        var name: String
        var startAt: String
        var endAt: String
        var userId: String
        var memo: String
        var notification: String
        var allDayToggle: String
        var createdAt: String
        var lastModifiedAt: String
    }

    func updateScheduleData(data: Format) {
        schedules.append(data)
    }

    
}
