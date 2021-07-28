//
//  ModalPlayerViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/06/24.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class ModalPlayerViewController: UIViewController {
    
    var player: PlayerModel!
    var playerModel: Results<PlayerModel>!
    var memoList: Results<MemoModel>!
    
    var datalist: String?
    var memoId:Int = 0
    var matchId:Int = 0
    
    var data = ["test1","test2","test3","test4","test5","test6","test7","test8","test9","test10","test11","test12","test13","test14","test15","test16","test17","test18","test19","test20","test21"]

    @IBOutlet weak var teamNameLabel: UILabel!

    @IBAction func playerRegistButoom(segue: UIStoryboardSegue) {
//        let from = segue.source as! PlayerListViewController  // <- 遷移先を取得する
        
        for row in 0..<data.count {
            let indexPath = IndexPath(row: row, section: 0)
            let cell: UITableViewCell =  self.playerList.cellForRow(at: indexPath) ?? UITableViewCell()
            print(row, cell.accessoryType)
            //遷移先ViewControllerのインスタンス取得
            let playerListViewController = self.storyboard?.instantiateViewController(withIdentifier: "player_list_view") as! PlayerListViewController
            //TableViewの値を遷移先に値渡し
            playerListViewController.playerName = cell.textLabel?.text ?? ""
            //画面遷移
            self.navigationController?.pushViewController(playerListViewController, animated: true)
        }


        //Int型からIndexPath型にキャスト
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//           //indexPathでセルを指定可能
//        let cell = self.checkSheetTableView.cellForRow(at: indexPath)
//        self.timerName = from.textField.text ?? ""      // 遷移先の値を取得して遷移元の変数に格納する
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.accessoryType = .checkmark
        // Realmにしたデータを保存
//        PlayerModel().createPlayer(matchId: self.matchId, memoId: self.memoId, Id: self.playerModel.count, name: String, finish: { [weak self]  in
//        guard let self = self else {return}
//        let tableCell:PlayerModel = PlayerModel()
//            tableCell.matchId = self.playerModel.count
//            tableCell.id = self.memoId
//            tableCell.playerId = self.matchId
//            self.playerListView.reloadData()
//        })
    }

    @IBOutlet weak var playerList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initView()
        getArticles()
        
        let realm = try! Realm()
        //試合結果の取得
        let matchPredicate = NSPredicate(format: "id == %d", memoId)
        self.playerModel = realm.objects(PlayerModel.self).filter(matchPredicate)
        //試合結果の絞り込み
        let matchFilter = NSPredicate(format: "matchId == %d", matchId)
        self.playerModel = realm.objects(PlayerModel.self).filter(matchFilter)
    
        if let data = self.datalist {
            //ラベルにチーム名を表示
            self.teamNameLabel.text = data
        }
        
    }
    
    func getArticles() {
        
        let url = "https://api-football-beta.p.rapidapi.com/players?season=2021&team=33&league=39"
        
        let headers: HTTPHeaders = ["x-rapidapi-key":"0cd2c70ebamsh7896448dc962eeep177866jsn4d5875e442ad", "x-rapidapi-host":"api-football-beta.p.rapidapi.com"]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
        
            guard let data = response.data else { return }
            let json:JSON = JSON(data as Any)
            print(data)
            self.data = []
            for i in 0..<json.count{
                print(json["response"][i]["player"]["name"].string) // 選手名を表示
                self.data.append(json["response"][i]["player"]["name"].string ?? "")
            }
            self.playerList.reloadData()
        }
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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
//        return playerModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell") {
            cell.textLabel?.text = data[indexPath.row]
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            print(cell)
            return cell
        } else {
            print("値が代入されていません")
        }
        return UITableViewCell()
    }
    
    //selectはずれたとき
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //checkmarkはずす
        cell?.accessoryType = .none
//        selectCell.remove(at: 0)
        tableView.deselectRow(at: indexPath, animated: true)
        }
}

//    // テーブルビューのセルをクリックしたら、アラートコントローラを表示する処理
//    func showTableAlert(_ indexPath: IndexPath){
//        let alertController: UIAlertController = UIAlertController(title: "編集", message: "選手情報の変更", preferredStyle: .alert)
//        // アラートコントローラにテキストフィールドを表示 テキストフィールドには入力された情報を表示させておく処理
//        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
//                                        // モデルクラスをインスタンス化
//                                        let tableCell:MatchModel = MatchModel()
//                                        textField.text = tableCell.matchResult})
//        // アラートコントローラに"OK"ボタンを表示 "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新する処理を実装
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in self.updateAlert(alertController,indexPath)
//        }))
//        // アラートコントローラに"Cancel"ボタンを表示
//        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    // "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新
//    func updateAlert(_ alertcontroller:UIAlertController, _ indexPath: IndexPath) {
//        // guard を利用して、nil チェック
//        guard let textFields = alertcontroller.textFields else {return}
//        guard let text = textFields[0].text else {return}
//
//        // Realm に保存したデータを UIAlertController に入力されたデータで更新
//        let realm = try! Realm()
//        try! realm.write{
//            playerModel[indexPath.row].playername = text
//        }
//        //self.playerList.reloadData()
//    }


//// MARK: MemoTableViewCellDelegate
//extension ModalPlayerViewController : MemoTableViewCellDelegate {
//
//    //編集ボタン
//    func onTapPencil(row: Int) {
//        showTableAlert(IndexPath(row: row, section: 0))
//    }
//
//    //セルの削除処理
//    func onTapButton(row: Int) {
//        //セルの削除処理
//        let realm = try! Realm()
//        // データを削除
//        try! realm.write {
//            realm.delete(playerModel[row])
//        }
//        //playerList.reloadData()
//    }
//
//
//}
