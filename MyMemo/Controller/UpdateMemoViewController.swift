//
//  UpdateMemoViewController.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import UIKit

class UpdateMemoViewController: UIViewController {

    
    //MARK: Property
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    //MARK: Method
    
    func addMemo() {
        guard let text = textView.text, !text.isEmpty else {
            print("DEBUG: 텍스트가 비어잇슴")
            return
        }
        
        let content = text.components(separatedBy: "\n").filter( { $0.isEmpty == false } )
        print(content)
    }
    
    func textViewConfig() {
        textView.text == ""
        
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
