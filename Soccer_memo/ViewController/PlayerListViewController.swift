//
//  PlayerListViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/21.
//

import UIKit

class PlayerListViewController: UIViewController {
    
    //遷移元から名前を取得用の変数を定義
    var datalist: String?
    // この配列に作ったアイテムを追加していく
    var itemArray: [Item] = []
    //メモした内容を保持しておくString配列playerList
    var playerList: [String] = []
    
   
    //選手名の表示ラベル
    @IBOutlet weak var playerName: UILabel!
    
    //TableViewの紐付け
    @IBOutlet weak var playerListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        //タイトル名設定
        navigationItem.title = "選手一覧"
        //テーブルビューのデリゲートを設定する。
        self.playerListView.delegate = self
        //テーブルビューのデータソースを設定する。
        self.playerListView.dataSource = self
        //self.datalistがnilでなければdataに代入する
        if let data = self.datalist {
            //ラベルに選手名を表示
            self.playerName.text = data
        }
    }
    
    // MARK: - Action
    @IBAction func playerAdd(_ sender: Any) {
        var textField = UITextField()
                let alert = UIAlertController(title: "アイテムを追加", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "リストに追加", style: .default) { (action) in
                    let newItem: Item = Item(title: textField.text!)
                    self.itemArray.append(newItem)
                    self.playerListView.reloadData()
                }

                alert.addTextField { (alertTextField) in
                    //プレースホルダーの設定
                    alertTextField.placeholder = "例：G.ドンナルンマ"
                    //テキストフィールドに設定
                    textField = alertTextField
                }

                alert.addAction(action)
                present(alert, animated: true, completion: nil)
    }
}


// MARK: - Tableview Delegate
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource  {
    // セルの数を指定ーitemArrayの配列の数だけCellを表示します
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Cellの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //「PlayerCell」を引っ張ってくる
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        //Cell番号のitemArrayを変数Itemに代入
        let item = itemArray[indexPath.row]
        //Cell番号のItemArrayの中身を表示させるようにしている
        cell.textLabel?.text = item.title
        //チェックマークを表示する処理ーitemのdoneがtrueだったら表示falseだったら非表示
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //メモ一覧のセルが選択されたイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= itemArray.count {
            return
        }
        //遷移先ViewControllerのインスタンス取得
        let scoringViewController = self.storyboard?.instantiateViewController(withIdentifier: "scoring_data_view") as! ScoringViewController
        //TableViewの値を遷移先に値渡し
        scoringViewController.dataInfo = itemArray[indexPath.row].title
        //画面遷移
        self.navigationController?.pushViewController(scoringViewController, animated: true)
    }
    
    //セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //セルの削除
            itemArray.remove(at: indexPath.row)
            playerListView.reloadData()
        }
    }
    
}
