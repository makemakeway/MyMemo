//
//  Extension+DateFormatter.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import Foundation


extension DateFormatter {
    func dateToString(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko-KR")
        df.timeZone = TimeZone(identifier: "KST")
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .weekday], from: date, to: Date())
        
        
        let writtenDateWeekday = calendar.component(.weekday, from: date)
        let todayWeekday = calendar.component(.weekday, from: Date())
        
        
        if calendar.isDateInToday(date) {
            df.dateFormat = "a hh:mm"
        } else if components.day! < 7 || writtenDateWeekday > todayWeekday {
            df.dateFormat = "EEEE"
        } else {
            df.dateFormat = "yyyy.MM.dd a HH:mm"
        }
        
        return df.string(from: date)
    }
}
