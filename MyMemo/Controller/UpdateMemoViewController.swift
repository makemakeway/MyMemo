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
    
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    //MARK: Method
    
    func addMemo() {
        if memo != nil && textView.text.isEmpty {
            // 받아온 데이터가 있는데, textView의 text를 삭제해서 비어있는 경우
            // 받아온 데이터의 pk로 데이터베이스 값을 찾아서 삭제해야함 지금 졸리니까 내일 구현해야지
        }
        
        guard let text = textView.text, !(text.isEmpty) else {
            print("DEBUG: 텍스트가 비어잇슴")
            return
        }
        
        let content = text.components(separatedBy: "\n")
        
        print(content)
        
        let title = content.filter( {$0.isEmpty == false} ).first ?? ""
        let count = content.count
        
        var body:String? = nil
        
        if count > 1 {
            body = content[1...count-1].joined(separator: "\n")
        }
        
        try! localRealm.write {
            localRealm.add(Memo(title: title, content: body, writtenDate: Date(), pinned: false))
        }

        print("stored at: \(localRealm.configuration.fileURL)")
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewConfig() {
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
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
        addMemo()
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
            self.textView.text = memo.title + (memo.content ?? "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textView.resignFirstResponder()
    }

}
