//
//  Core.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/11.
//

import Foundation

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
