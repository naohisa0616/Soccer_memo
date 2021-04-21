//
//  MemoTableViewCell.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/04/16.
//

import UIKit

class MemoTableViewCell: UITableViewCell {

    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var teamImg: UIImageView!
    
    @IBAction func tapDeleteAction(_ sender: Any) {
        print("ボタン")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
