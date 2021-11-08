//
//  Extension+DateFormatter.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import Foundation


extension DateFormatter {
    var df: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko-KR")
        df.timeZone = TimeZone(identifier: "KST")
        return df
    }
    
    func dateToString(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko-KR")
        df.timeZone = TimeZone(identifier: "KST")
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            df.dateFormat = "a hh:mm"
        } else if calendar.dateComponents([.weekday], from: date, to: Date()).weekday! < 7 {
            df.dateFormat = "EEEE"
        } else {
            df.dateFormat = "yyyy.MM.dd a HH:mm"
        }
        
        print(calendar.dateComponents([.day, .weekday], from: date, to: Date()))
        
        
        return df.string(from: date)
    }
}
