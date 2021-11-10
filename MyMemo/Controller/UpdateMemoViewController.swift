//
//  UpdateMemoViewController.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import UIKit
import RealmSwift

class UpdateMemoViewController: UIViewController {

    
    //MARK: Property
    
    var localRealm = try! Realm()
    
    var memo: Memo?

    var updated = false
    
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    //MARK: Method
    
    func separateTitleAndBody() -> [String?] {
        guard let text = textView.text, !(text.isEmpty) else {
            print("DEBUG: 텍스트가 비어잇슴")
            return []
        }
        
        let content = text.components(separatedBy: "\n")
        
        let title = content.filter( {$0.isEmpty == false} ).first ?? ""
        let count = content.count
        
        var body:String? = nil
        
        if count > 1 {
            body = content[1...count-1].joined(separator: "\n")
        }
        
        var result = [String?]()
        result.append(title)
        result.append(body)
        
        return result
    }
    
    func addMemo() {
        
        var result = separateTitleAndBody()
        
        let title = result.removeFirst()!
        let body: String? = result.removeFirst()
        
        try! localRealm.write {
            localRealm.add(Memo(title: title, content: body, writtenDate: Date(), pinned: false))
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateMemo() {
        var result = separateTitleAndBody()
        
        
        
        if memo != nil && textView.text.isEmpty {
            // 받아온 데이터가 있고, textView의 text가 비어있는 경우
            try! localRealm.write {
                localRealm.delete(memo!)
            }
            return
        }
        else if memo != nil && !(textView.text.isEmpty) {
            // 받아온 데이터가 있고, textView의 text가 비어있지 않은 경우
            
            let title = result.removeFirst()
            let body: String? = result.removeFirst()
            
            try! localRealm.write {
                memo!.title = title!
                memo!.content = body
                memo!.writtenDate = Date()
            }
        }
        else if memo == nil && !(textView.text.isEmpty) {
            // 받아온 데이터가 없고, textView의 text가 비어있지 않은 경우
            
            let title = result.removeFirst()
            let body: String? = result.removeFirst()
            
            try! localRealm.write {
                localRealm.add(Memo(title: title!, content: body, writtenDate: Date(), pinned: false))
            }
        }
        else {
            // 받아온 데이터가 없고, textView의 text가 비어있는 경우
            return
        }
        
    }
    
    func textViewConfig() {
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
    }
    
    func navBarConfig() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked(_:)))
        
        let completeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonClicked(_:)))
        
        self.navigationItem.rightBarButtonItems = [completeButton, shareButton]
    }
    
    
    //MARK: Objc Method
    @objc func shareButtonClicked(_ sender: UIBarButtonItem) {
        print("공유")
    }
    
    @objc func completeButtonClicked(_ sender: UIBarButtonItem) {
        print("완료")
        updateMemo()
        updated = true
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarConfig()
        textViewConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
        if let memo = memo {
            self.textView.text = memo.title + "\n" + (memo.content ?? "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if updated == false {
            updateMemo()
        }
        self.textView.resignFirstResponder()
    }

}

extension UpdateMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.updated = false
    }
}
