//
//  DetailViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/02/19.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
    // モデルクラスを使用し、取得データを格納する変数を作成
    var memoList: Results<MemoModel>!
    
    //TableViewの紐付け
    @IBOutlet weak var detailListView: UITableView!
    //追加ボタン
    @IBAction func addMatchInfo(_ sender: Any) {
        var textField = UITextField()
                let alert = UIAlertController(title: "アイテムを追加", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "リストに追加", style: .default) { (action) in
                    let newItem: Item = Item(title: textField.text!)
                    // モデルクラスをインスタンス化
                    let tableCell:MemoModel = MemoModel()
                    // Realmインスタンス取得
                    let realm = try! Realm()
                    // テキストフィールドの名前を入れる
                    tableCell.memo = newItem.title
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    // テキストフィールドの情報をデータベースに追加
                    try! realm.write {
                        realm.add(tableCell)
                    }
                    self.detailListView.reloadData()
                }
                
                alert.addTextField { (alertTextField) in
                    //プレースホルダーの設定
                    alertTextField.placeholder = "例：ACミラン vs マンU 2-1"
                    //テキストフィールドに設定
                    textField = alertTextField
                }
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
    }
    
    //選手名の表示ラベル
    @IBOutlet weak var playerName: UILabel!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            // デフォルトの画像を表示する
            imageView.image = UIImage(named: "no_image.png")
        }
    }
    
    @IBAction func selectPicture(_ sender: UIButton) {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    @IBAction func deletePicture(_ sender: UIButton) {
        // アラート表示
        showAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        //タイトル名設定
        navigationItem.title = "試合管理"
        //テーブルビューのデリゲートを設定する。
        self.detailListView.delegate = self
        //テーブルビューのデータソースを設定する。
        self.detailListView.dataSource = self
        // 永続化されているデータを取りだす
        let realm = try! Realm()
        // データ全件取得
        self.memoList = realm.objects(MemoModel.self)
        detailListView.reloadData()
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        detailListView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        //self.dataがnilでなければdataに代入する
        if let data = self.data {
            //ラベルに選手名を表示
            self.playerName.text = data
        }
    }
    
    // セルの数を指定ーitemArrayの配列の数だけCellを表示します
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    // Cellの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //「DetailCell」を引っ張ってくる
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        //Cell番号のitemArrayを変数Itemに代入
        let item = memoList[indexPath.row].memo
        //ToDoCellにCell番号のmemoListの中身を表示させるようにしている
        cell.textLabel?.text = item
        return cell
    }
    
    //メモ一覧のセルが選択されたイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= memoList.count {
            return
        }
        //遷移先ViewControllerのインスタンス取得
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player_list_view") as! PlayerListViewController
        //TableViewの値を遷移先に値渡し
        playerViewController.datalist = memoList[indexPath.row].memo
        //画面遷移
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    //セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //セルの削除
            let realm = try! Realm()
            // データを削除
            try! realm.write {
                realm.delete(memoList[indexPath.row])
            }
            detailListView.reloadData()
        }
    }
    
    // アラート表示
    func showAlert() {
        let alert = UIAlertController(title: "確認",
                                      message: "画像を削除してもいいですか？",
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler:{(action: UIAlertAction) -> Void in
                                        // デフォルトの画像を表示する
                                        self.imageView.image = UIImage(named: "no_image.png")
                                     })
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        // アラートにボタン追加
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        // アラート表示
        present(alert, animated: true, completion: nil)
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真を取得する
        let image = info[.originalImage] as! UIImage
        // ビューに表示する
        imageView.image = image
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
}
