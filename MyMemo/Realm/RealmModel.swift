//
//  RealmModel.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import Foundation
import RealmSwift

class Memo: Object {
    @Persisted var title: String
    @Persisted var content: String?
    @Persisted var writtenDate: Date
    
    convenience init(title: String, content: String?, writtenDate: Date) {
        self.init()
        self.title = title
        self.content = content
        self.writtenDate = writtenDate
    }
}
