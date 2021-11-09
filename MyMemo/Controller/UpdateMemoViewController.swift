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
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    //MARK: Method
    
    func addMemo() {
        guard let text = textView.text, !(text.isEmpty) else {
            print("DEBUG: 텍스트가 비어잇슴")
            return
        }
        
        let content = text.components(separatedBy: "\n")
        
        print(content)
        
        let title = content[0]
        let count = content.count
        
        var body:String? = nil
        
        if count > 1 {
            body = content[1...count-1].joined(separator: "\n")
        }
        
        print(body?.components(separatedBy: "\n").filter({ $0.isEmpty == false }).isEmpty)
        
        try! localRealm.write {
            localRealm.add(Memo(title: title, content: body, writtenDate: Date(), pinned: false))
        }

        print("stored at: \(localRealm.configuration.fileURL)")
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewConfig() {
        textView.text = ""
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textView.resignFirstResponder()
    }

}
