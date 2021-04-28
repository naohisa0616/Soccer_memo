//
//  DetailViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/02/19.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TableDelegate, UpdateDelegate {
    
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
    var match: Results<MatchModel>!
    var memoList: Results<MemoModel>!
    
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    // ドキュメントディレクトリの「パス」（String型）定義
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let realm = try! Realm()

    //TableViewの紐付け
    @IBOutlet weak var detailListView: UITableView!
    //追加ボタン
    @IBAction func addMatchInfo(_ sender: Any) {
        var textField = UITextField()
                let alert = UIAlertController(title: "試合情報を追加", message: "", preferredStyle: .alert)
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
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    //削除ボタン
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
//        //画像の表示
//        tableData = realm.objects(MemoModel.self)
//        //URL型にキャスト
//        let fileURL = URL(string: tableData[0].imageURL)
//        //パス型に変換
//        let filePath = fileURL?.path
//        showImageView.image = UIImage(contentsOfFile: filePath!)
        
        let users = MemoModel.loadAll()
//        for (i, user) in users.enumerate() {
//            let imageView = UIImageView()
//            imageView.image = user.image
//            self.view.addSubview(imageView)
//        }
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
        let item = match[indexPath.row].matchResult
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
        playerViewController.datalist = memoList[indexPath.row].memo //チーム名
        //画面遷移
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    //セルの削除処理
    func onTapButton(row: Int) {
        //セルの削除処理
        let realm = try! Realm()
        // データを削除
        try! realm.write {
            realm.delete(match[row])
        }
        detailListView.reloadData()
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
        //写真の保存
//        let photo = MemoModel.create()
//        photo.image = image
//        photo.save()
        // ビューに表示する
        imageView.image = image
        //Realmのテーブルをインスタンス化
        let photo = MemoModel()
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        do{
            try photo.imageURL = directory.documentDirectoryFileURL.absoluteString
        }catch{
            print("画像の保存に失敗しました")
        }
        try! realm.write{realm.add(photo)}
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    //編集ボタン
    func onTapPencil(row: Int) {
        //showAlert(IndexPath)
//        updateAlert(UIAlertController, IndexPath)
    }
    
    // テーブルビューのセルをクリックしたら、アラートコントローラを表示する処理
    func showAlert(_ indexPath: IndexPath){
        let alertController: UIAlertController = UIAlertController(title: "編集", message: "試合情報の変更", preferredStyle: .alert)
        // アラートコントローラにテキストフィールドを表示 テキストフィールドには入力された情報を表示させておく処理
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
                                        // モデルクラスをインスタンス化
                                        let tableCell:MatchModel = MatchModel()
                                        textField.text = tableCell.matchResult})
        // アラートコントローラに"OK"ボタンを表示 "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新する処理を実装
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
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

        // UIAlertController に入力された文字をコンソールに出力
        print(text)

        // Realm に保存したデータを UIAlertController に入力されたデータで更新
        let realm = try! Realm()
        try! realm.write{
            match[indexPath.row].matchResult = text
        }
        self.detailListView.reloadData()
    }
    
    //保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "\(NSUUID().uuidString).png"

        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
        }
    }
    
    //画像を保存する関数の部分
    func saveImage() {
        createLocalDataFile()
        //pngで保存する場合
        let pngImageData = imageView.image?.pngData()
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
        } catch {
            //エラー処理
            print("エラー")
        }
    }
    
}
