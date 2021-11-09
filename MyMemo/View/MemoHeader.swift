//
//  MemoHeader.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/09.
//

import UIKit

class MemoHeader: UITableViewHeaderFooterView {

    static let identifier = "MemoHeader"
    
    var titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0,
                                  y: 0,
                                  width: contentView.frame.size.width,
                                  height: contentView.frame.size.height)
        
    }
    
}
