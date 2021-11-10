//
//  Extension+NumberFormatter.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/10.
//

import Foundation

extension NumberFormatter {
    static func numberToString(num: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        return nf.string(from: NSNumber(value: num))!
    }
}
