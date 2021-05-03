//
//  MemoTableViewCell.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/04/16.
//

import UIKit

//プロトコルの宣言
protocol MemoTableViewCellDelegate {
    func onTapButton(row: Int)
    func onTapPencil(row: Int)
}

class MemoTableViewCell: UITableViewCell {
    
    //delegateの宣言
    var memoTableViewCellDelegate: MemoTableViewCellDelegate?
    var row: Int = 0
    
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var teamImg: UIImageView!
    
    @IBAction func tapDeleteAction(_ sender: Any) {
        //delegate設置
        self.memoTableViewCellDelegate?.onTapPencil(row: row)
    }
    @IBAction func tapEditAction(_ sender: Any) {
        //delegate設置
        self.memoTableViewCellDelegate?.onTapButton(row: row)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


