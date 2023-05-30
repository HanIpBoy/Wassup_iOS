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
    case "0" : return UIColor(hexString: "E45C5C")
    case "1" : return UIColor(hexString: "F37C39")
    case "2" : return UIColor(hexString: "F2DD1B")
    case "3" : return UIColor(hexString: "2CC91E")
    case "4" : return UIColor(hexString: "474DDF")
    case "5" : return UIColor(hexString: "311E7B")
    case "6" : return UIColor(hexString: "B04BD3")
    case "7" : return UIColor(hexString: "FF4BE2")
    case "8" : return UIColor(hexString: "000000")
    case "9" : return UIColor(hexString: "7B4C15")
    case "10" : return UIColor(hexString: "73FCD6") // 그룹 일정을 타임테이블에 표시할 때, 사용할 색상 인덱스는 10
    default : return UIColor(hexString: "ffffff")
    }
}

public func makeBorderForCollectionView(collectionView : UICollectionView) {
    collectionView.layer.borderColor = UIColor.black.cgColor
    collectionView.layer.borderWidth = 0.7
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


