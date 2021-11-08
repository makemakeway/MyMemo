//
//  MemoTableViewCell.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import UIKit

class MemoTableViewCell: UITableViewCell {
    
    static let identifier = "MemoTableViewCell"
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
