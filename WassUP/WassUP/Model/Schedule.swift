//
//  Schedule.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/15.
//

import Foundation

class Schedule {
    static let shared = Schedule()
    var schedules: [Format] = []
    var groupSchedules: [Format] = []

    private init() {}

    struct Format {
        var originKey: String
        var name: String
        var startAt: String
        var endAt: String
        var userId: String
        var memo: String
        var allDayToggle: String
        var color: String
    }

    func updateScheduleData(data: Format) {
        schedules.append(data)
    }
    
    func updateGroupScheduleData(data: Format) {
        groupSchedules.append(data)
    }
    func findAndUpdateScheduleData(data: Format) {
        if let index = Schedule.shared.schedules.firstIndex(where: { $0.originKey == data.originKey }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            schedules[index] = data
        }
    }
    func deleteScheduleData(data: Format) {
        if let index = Schedule.shared.schedules.firstIndex(where: { $0.originKey == data.originKey }) {
            // 특정 식별자를 가진 아이템의 인덱스를 찾음
            schedules.remove(at: index)
        }
    }
}
