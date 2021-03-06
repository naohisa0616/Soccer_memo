//
//  DetailViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/02/19.
//

import UIKit

class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // アイテムの型
    class Item {
        var title : String
        var done: Bool = false
        
        init(title: String) {
            self.title = title
        }
    }
    
    //遷移元から名前を取得用の変数を定義
    var data: String?
    // この配列に作ったアイテムを追加していく
    var itemArray: [Item] = []
    
    //TableViewの紐付け
    @IBOutlet weak var detailListView: UITableView!
    //追加ボタン
    @IBAction func addMatchInfo(_ sender: Any) {
        var textField = UITextField()
                let alert = UIAlertController(title: "アイテムを追加", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "リストに追加", style: .default) { (action) in
                    let newItem: Item = Item(title: textField.text!)
                    self.itemArray.append(newItem)
                    self.detailListView.reloadData()
                }
                
                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "NEWアイテム"
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
        //テーブルビューのデリゲートを設定する。
        self.detailListView.delegate = self
        //テーブルビューのデータソースを設定する。
        self.detailListView.dataSource = self
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        detailListView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        if let data = self.data {
            //ラベルに選手名を表示
            self.playerName.text = data
        }
    }
    
    // セルの数を指定ーitemArrayの配列の数だけCellを表示します
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Cellの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //「DetailCell」を引っ張ってくる
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        //Cell番号のitemArrayを変数Itemに代入
        let item = itemArray[indexPath.row]
        //ToDoCellにCell番号のItemArrayの中身を表示させるようにしている
        cell.textLabel?.text = item.title
        //チェックマークを表示する処理ーitemのdoneがtrueだったら表示falseだったら非表示
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
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
