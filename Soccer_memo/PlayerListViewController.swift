//
//  PlayerListViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/21.
//

import UIKit

class PlayerListViewController: UIViewController {

    // アイテムの型
    struct Item {
        //ストアドプロパティ
        var title : String
        var done: Bool = false
        
        init(title: String) {
            //メンバ変数の名前とイニシャライザの引数の名前を区別
            self.title = title
        }
    }
    
    //遷移元から名前を取得用の変数を定義
    var data: String?
    
    // この配列に作ったアイテムを追加していく
    var itemArray: [Item] = []
    //メモした内容を保持しておくString配列matchList
    var playerList: [String] = []
    
    //選手名の表示ラベル
    @IBOutlet weak var playerName: UILabel!
    
    //TableViewの紐付け
    @IBOutlet weak var playerListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
