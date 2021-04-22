//
//  MemoTableViewCell.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/04/16.
//

import UIKit

class MemoTableViewCell: UITableViewCell {
    
    //delegateの宣言
    var tableDelegate: TableDelegate?
    
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var teamImg: UIImageView!
    
    @IBAction func tapDeleteAction(_ sender: Any) {
        
    }
    @IBAction func tapEditAction(_ sender: Any) {
        //delegate設置
        self.tableDelegate?.onTapButton()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//プロトコルの宣言
protocol TableDelegate: class {
   func onTapButton()
}
