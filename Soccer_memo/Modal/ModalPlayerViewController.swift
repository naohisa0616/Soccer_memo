//
//  ModalPlayerViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/06/24.
//

import UIKit
import RealmSwift

class ModalPlayerViewController: UIViewController {
    
    var playerModel: Results<PlayerModel>!

    @IBOutlet weak var teamName: UILabel!
    
    @IBOutlet weak var playerRegist: UIButton!
    
    @IBOutlet weak var playerList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initView()
    }
    
}

extension ModalPlayerViewController {
    private func initView() {
        playerList.delegate = self
        playerList.dataSource = self
        // 複数選択可にする
        playerList.allowsMultipleSelection = true
    }
}

// MARK: - Tableview Delegate
extension ModalPlayerViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath as IndexPath) as? MemoTableViewCell {
            cell.memoTableViewCellDelegate = self
            cell.row = indexPath.row
        let item = self.playerModel[indexPath.row]
        cell.teamName.text = item.playername
        return cell
        }
        return UITableViewCell()
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
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
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
            playerModel[indexPath.row].playername = text
        }
        self.playerList.reloadData()
    }
}

// MARK: MemoTableViewCellDelegate
extension ModalPlayerViewController : MemoTableViewCellDelegate {
    
    //編集ボタン
    func onTapPencil(row: Int) {
        showTableAlert(IndexPath(row: row, section: 0))
    }
    
    //セルの削除処理
    func onTapButton(row: Int) {
        //セルの削除処理
        let realm = try! Realm()
        // データを削除
        try! realm.write {
            realm.delete(playerModel[row])
        }
        playerList.reloadData()
    }
    
    
}
