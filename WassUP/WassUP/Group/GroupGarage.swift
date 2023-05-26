//
//  GroupGarage.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/24.
//

import Foundation
import UIKit

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

struct Bar {
    var userId: String
    var userIndex: String
    var startHour: String
    var startMinute: String
    var endHour: String
    var endMinute: String
    var weekday: String
}

public func getNextWeek(from date: Date) -> Date? {
    let calendar = Calendar.current
    let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: date)
    return nextWeek
}

public func getPreviousWeek(from date: Date) -> Date? {
    let calendar = Calendar.current
    let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: date)
    return previousWeek
}

public func makePeriodLabel(startDate: Date, endDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M.d"
    let calendar = Calendar.current

    let endDateModified = calendar.date(byAdding: .day, value: -1, to: endDate)
    
    let startString = dateFormatter.string(from: startDate)
    let endString = dateFormatter.string(from: endDateModified!)

    return "\(startString) - \(endString)"
}

public func colorVendingMachine(index : String) -> UIColor {
    switch index {
    case "0" : return .red
    case "1" : return .orange
    case "2" : return .yellow
    case "3" : return .green
    case "4" : return .cyan
    case "5" : return .blue
    case "6" : return .purple
    case "7" : return .systemPink
    case "8" : return .black
    case "9" : return .brown
    default: return .white
    }
}

public func makeBorderForCollectionView(collectionView : UICollectionView) {
    collectionView.layer.borderColor = UIColor.lightGray.cgColor
    collectionView.layer.borderWidth = 0.5
}

public func isDate(_ date: Date, between startDate: Date, and endDate: Date) -> Bool {
    return date >= startDate && date < endDate
}

public func getPreviousSundayAndCurrentSaturday(today : Date) -> (previousSunday: Date, currentSaturday: Date) {
    let calendar = Calendar.current
    
    // 전주 일요일 찾기
    let sundayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
    guard let previousSunday = calendar.date(from: sundayComponents) else {
        fatalError("Failed to calculate previous Sunday.")
    }
    
    // 이번주 일요일 찾기
    let sundayComponent = DateComponents(weekday: 1)
    guard let currentSunday = calendar.nextDate(after: today, matching: sundayComponent, matchingPolicy: .nextTime) else {
        fatalError("Failed to calculate current Sunday.")
    }
    
    return (previousSunday, currentSunday)
}


