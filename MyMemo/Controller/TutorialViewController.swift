//
//  TutorialViewController.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/11.
//

import UIKit

class TutorialViewController: UIViewController {

    
    //MARK: Property
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    
    //MARK: Method
    
    func okButtonConfig() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            var attText = AttributedString("확인")
            attText.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            
            config.cornerStyle = .dynamic
            config.baseBackgroundColor = .orange
            config.baseForegroundColor = .white
            config.attributedTitle = attText
            
            
            okButton.configuration = config
        } else {
            okButton.layer.cornerRadius = 10
            okButton.backgroundColor = .orange
            okButton.tintColor = .white
            okButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        }
        
    }
    
    func contentViewConfig() {
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .systemGray6
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.layer.borderWidth = 2
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        Core.shared.setIsNotNewUser()
        dismiss(animated: false, completion: nil)
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        okButtonConfig()
        contentViewConfig()
        view.backgroundColor = .clear
    }
}
