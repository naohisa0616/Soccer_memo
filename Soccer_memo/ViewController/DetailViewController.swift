//
//  DetailViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/02/19.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, MemoTableViewCellDelegate {
    
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
    var teamName: String = ""
    var matchResult:String = ""
    var Id:Int = 0
    // モデルクラスを使用し、取得データを格納する変数を作成
    var matchList: Results<MatchModel>!
    var memoList: Results<MemoModel>!
    
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    // ドキュメントディレクトリの「パス」（String型）定義
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let realm = try! Realm()

    @IBOutlet weak var detailListView: UITableView!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            // デフォルトの画像を表示する
            imageView.image = UIImage(named: "no_image.png")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        //タイトル名設定
        navigationItem.title = "試合管理"
//        self.view.bringSubviewToFront(selectPicture)
        self.detailListView.delegate = self
        self.detailListView.dataSource = self
        let realm = try! Realm()
        
        // チーム情報取得
        let predicate = NSPredicate(format: "memo == %@", teamName)
        self.memoList = realm.objects(MemoModel.self).filter(predicate)
        
        //試合結果の取得
        let matchPredicate = NSPredicate(format: "memoId == %d", Id)
        self.matchList = realm.objects(MatchModel.self).filter(matchPredicate)
        detailListView.reloadData()
        detailListView.register(UINib(nibName: "MemoTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
        self.teamNameLabel.text = teamName

        //画像の表示
        let imageData = realm.objects(MemoModel.self)
        imageView.image = imageData[0].image
        
        let users = MemoModel.loadAll()
        for (i, user) in users.enumerated() {
            let imageView = UIImageView()
            imageView.image = user.image
            self.view.addSubview(imageView)
        }
    }
    
    // MARK:-  Private
    private func createMatch(text: String, Id: Int) {
        let matchItem:MatchModel = MatchModel()
        matchItem.create(text: text, finish:  { [weak self]  in
            guard let self = self else {return}
            self.detailListView.reloadData()
        }, Id: Id, matchId: self.matchList.count)
        
    }
    
    

    
    // MARK: - Button Action
    //追加ボタン
    @IBAction func addMatchInfo(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "試合情報を追加", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "リストに追加", style: .default) { (action) in
            self.createMatch(text: textField.text ?? "", Id: self.Id)
            let tableCell:MatchModel = MatchModel()
            tableCell.memoId = self.matchList.count
            tableCell.id = self.Id
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default)
        
        alert.addTextField { (alertTextField) in
            //プレースホルダーの設定
            alertTextField.placeholder = "例：ACミラン vs マンU 2-1"
            //テキストフィールドに設定
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
    
    //セルの削除処理
    func onTapButton(row: Int) {
        //セルの削除処理
        let realm = try! Realm()
        // データを削除
        try! realm.write {
            realm.delete(matchList[row])
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

                                        let predicate = NSPredicate(format: "memo == %@", self.teamName)
                                        let imageData = self.realm.objects(MemoModel.self).filter(predicate)
                                        if imageData.count == 0 { return }
                                        //URL型にキャスト
                                        let fileURL = URL(string: imageData[0].image.debugDescription)
                                        let filePath = fileURL?.path
                                        //ファイルの削除
                                        if filePath != nil{
                                            try? FileManager.default.removeItem(atPath: filePath!)
                                        }
                                        //画像データの削除
                                        try! self.realm.write{
                                            imageData[0].image = nil
                                            self.imageView.image = nil
                                        }
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
        let predicate = NSPredicate(format: "memo == %@", self.teamName)
        let imageData = self.realm.objects(MemoModel.self).filter(predicate)
        if imageData.count == 0 { return }
        imageView.image = image
        try! realm.write{
            imageData[0].image = image
        }
        self.dismiss(animated: true)
    }
    
    //編集ボタン
    func onTapPencil(row: Int) {
        showTableAlert(IndexPath(row: row, section: 0))
    }
    
    // テーブルビューのセルをクリックしたら、アラートコントローラを表示する処理
    func showTableAlert(_ indexPath: IndexPath){
        let alertController: UIAlertController = UIAlertController(title: "編集", message: "試合情報の変更", preferredStyle: .alert)
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
        // モデルクラスをインスタンス化
        let tableCell:MatchModel = MatchModel()

        // Realm に保存したデータを UIAlertController に入力されたデータで更新
        let realm = try! Realm()
        try! realm.write{
            matchList[indexPath.row].matchResult = text
            tableCell.memoId = Id
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

// MARK: - UITableViewDelegate & DataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルの数を指定ーitemArrayの配列の数だけCellを表示します
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchList.count
    }
    
    // Cellの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //「DetailCell」を引っ張ってくる
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath as IndexPath) as? MemoTableViewCell {
            cell.memoTableViewCellDelegate = self
            cell.row = indexPath.row
        //Cell番号のitemArrayを変数Itemに代入
        let item = matchList[indexPath.row].matchResult
        cell.teamName.text = item
//        let image = memoList[0].image
//            cell.teamImg.image = image
        return cell
        }
        return UITableViewCell()
    }
    
    //メモ一覧のセルが選択されたイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= matchList.count {
            return
        }
        //遷移先ViewControllerのインスタンス取得
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "player_list_view") as! PlayerListViewController
        //TableViewの値を遷移先に値渡し
        print(memoList.count)
        print(indexPath.row)
        playerViewController.datalist = memoList[0].memo //チーム名
        playerViewController.memoId = matchList[indexPath.row].memoId
        playerViewController.matchId = matchList[indexPath.row].id
        //画面遷移
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
}
