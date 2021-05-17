//
//  PlayerListViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/21.
//

import UIKit
import RealmSwift

class PlayerListViewController: UIViewController {
    
    // モデルクラスを使用し、取得データを格納する変数を作成
    var player: Results<PlayerModel>!
    var datalist: String?
    var itemArray: [Item] = []
    var playerList: [String] = []
    
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "選手一覧"
        self.playerListView.delegate = self
        self.playerListView.dataSource = self
        let realm = try! Realm()
        
//        // チーム情報取得
//        let predicate = NSPredicate(format: "memo == %@", playername)
//        self.memoList = realm.objects(PlayerModel.self).filter(predicate)
        // 選手名取得
        self.player = realm.objects(PlayerModel.self)
        playerListView.reloadData()
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        playerListView.register(UINib(nibName: "MemoTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
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
                    alertTextField.placeholder = "例：G.ドンナルンマ"
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
    
    // テーブルビューのセルをクリックしたら、アラートコントローラを表示する処理
    func showTableAlert(_ indexPath: IndexPath){
        let alertController: UIAlertController = UIAlertController(title: "編集", message: "選手情報の変更", preferredStyle: .alert)
        // アラートコントローラにテキストフィールドを表示 テキストフィールドには入力された情報を表示させておく処理
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
                                        // モデルクラスをインスタンス化
                                        let tableCell:MatchModel = MatchModel()
                                        textField.text = tableCell.matchResult})
        // アラートコントローラに"OK"ボタンを表示 "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新する処理を実装
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in self.updateAlert(alertController,indexPath)
        }))
        // アラートコントローラに"Cancel"ボタンを表示
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新
    func updateAlert(_ alertcontroller:UIAlertController, _ indexPath: IndexPath) {
        // guard を利用して、nil チェック
        guard let textFields = alertcontroller.textFields else {return}
        guard let text = textFields[0].text else {return}

        // Realm に保存したデータを UIAlertController に入力されたデータで更新
        let realm = try! Realm()
        try! realm.write{
            player[indexPath.row].playername = text
        }
        self.playerListView.reloadData()
    }

    
}

// MARK: MemoTableViewCellDelegate
extension PlayerListViewController : MemoTableViewCellDelegate {
    
    //編集ボタン
    func onTapPencil(row: Int) {
        showTableAlert(IndexPath(row: 0, section: 0))
    }
    
    //セルの削除処理
    func onTapButton(row: Int) {
        //セルの削除処理
        let realm = try! Realm()
        // データを削除
        try! realm.write {
            realm.delete(player[row])
        }
        playerListView.reloadData()
    }
    
    
}
