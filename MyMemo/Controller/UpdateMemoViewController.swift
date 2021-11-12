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
    
    var searchText: UILabel? = nil
    
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    //MARK: Method
    
    func separateTitleAndBody() -> [String?] {
        guard let text = textView.text, !(text.isEmpty) else {
            print("DEBUG: 텍스트가 비어잇슴")
            return []
        }
        
        let content = text.components(separatedBy: "\n")
        
        print("content: \(content)")
        
        var title = ""
        
        var titleIndex = 0
        
        for (index, text) in content.enumerated() {
            if !(text.isEmpty) {
                title = text
                titleIndex = index
                break
            }
        }
        
        title = String(repeating: "\n", count: titleIndex) + title
        
        var body:String? = nil
        
        let bodyIndex = titleIndex + 1
        
        
        if content.count > bodyIndex {
            body = content[bodyIndex...].joined(separator: "\n")
        }
        
        print(title, body)
        
        var result = [String?]()
        result.append(title)
        result.append(body)
        
        return result
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
        textView.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textView.delegate = self
    }
    
    func navBarConfig() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked(_:)))
        
        let completeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonClicked(_:)))
        
        self.navigationItem.rightBarButtonItems = [completeButton, shareButton]
    }
    
    func presentActivityController(sharedObject: [String]) {
        let activityViewController = UIActivityViewController(activityItems: sharedObject, applicationActivities: [])
        
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    //MARK: Objc Method
    @objc func shareButtonClicked(_ sender: UIBarButtonItem) {
        print("공유")
        
        if textView.text.isEmpty {
            let alert = UIAlertController(title: nil, message: "공유할 내용이 없습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
        var shared = [String]()
        
        shared.append(textView.text)
        
        presentActivityController(sharedObject: shared)
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
        // 텍스트뷰의 값이 바뀌면, 새로 반영을 해야하니까 updated를 false로 설정
        self.updated = false
    }
}
