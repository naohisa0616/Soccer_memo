//
//  ViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/01/02.
//

import UIKit
import RealmSwift

private let unselectedRow = -1

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,TableDelegate,UpdateDelegate {
    
    //確定ボタンがタップされたイベントでは、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    @IBAction func confirmButton(_ sender: Any) {
        applyMemo()
    }
    @IBOutlet weak var buttonEnabled: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var player_name: UILabel!
    @IBOutlet weak var memoListView: UITableView!
    //画面タップでキーボードを下げる
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        //編集終了でキーボードを下げる
        view.endEditing(true)
    }
    //編集中の行番号を保持する editRow をメンバ変数として定義
    var editRow: Int = unselectedRow
    // モデルクラスを使用し、取得データを格納する変数を作成
    var memoList: Results<MemoModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // 永続化されているデータを取りだす
        let realm = try! Realm()
        // データ全件取得
        self.memoList = realm.objects(MemoModel.self)
        memoListView.reloadData()
        //タイトル名設定
        navigationItem.title = "Player Scoring"
        self.memoListView.delegate = self
        self.memoListView.dataSource = self
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        memoListView.register(UINib(nibName: "MemoTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        textField.text = ""
        buttonEnabled.isEnabled = false
        textField.addTarget(self, action:#selector(textFieldDidChange),for: UIControl.Event.editingChanged)
        //placeholderを装飾する
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.lightGray // カラー
        ]
        //placeholderを設定
        textField.attributedPlaceholder = NSAttributedString(string: "チーム名を入力", attributes: attributes)
    }
    
    // 追加 画面が表示される際などにtableViewのデータを再読み込みする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoListView.reloadData()
    }
    
    //実行中のアプリがiPhoneのメモリを使いすぎた際に呼び出される。
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func textFieldDidChange(){
        buttonEnabled.isEnabled = !(textField.text?.isEmpty ?? true)
    }
    
    //セクションごとの行数を返す。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        self.memoList = realm.objects(MemoModel.self)
        return self.memoList.count
    }
    
    //メモ一覧が表示する内容を返すメソッド
    // 宣言したmemoListが保持している行番号に対応したメモを返すように実装。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath as IndexPath) as? MemoTableViewCell {
            cell.tableDelegate = self
            cell.row = indexPath.row
        if indexPath.row >= memoList.count {
            return cell
        }
        cell.teamName.text = memoList[indexPath.row].memo
        return cell
        }
        return UITableViewCell()
    }
    
    //メモ一覧のセルが選択されたイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= memoList.count {
            return
        }
        //遷移先ViewControllerのインスタンス取得
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "playerData") as! DetailViewController
        //TableViewの値を遷移先に値渡し
        detailViewController.data = memoList[indexPath.row].memo
        //画面遷移
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    //MemoTableViewCellからのdelegate処理
    func onTapButton(row: Int) {
        //セルの削除処理
        let realm = try! Realm()
        // データを削除
        try! realm.write {
            realm.delete(memoList[row])
        }
        memoListView.reloadData()
    }

    //改行されたイベントでは確定ボタンタップイベントと同様に、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyMemo()
        return true
    }
    
    //メモの入力を確定するメソッドでは、追加モードか編集モードかを判定し、memoListに対して入力テキストの追加、または上書きを行い、 編集モードから追加モードへの変更、メモ一覧の更新を行うように実装。
    func applyMemo() {
        if textField.text == nil {
            return
        }
        buttonEnabled.isEnabled = false
        editRow = unselectedRow
        // モデルクラスをインスタンス化
        let tableCell:MemoModel = MemoModel()
        // Realmインスタンス取得
        let realm = try! Realm()
        // テキストフィールドの名前を入れる
        tableCell.memo = self.textField.text
        tableCell.teamId = memoList.count
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // テキストフィールドの情報をデータベースに追加
        try! realm.write {
            realm.add(tableCell)
        }
        //TextField の内容のクリア
        textField.text = ""
        //メモリリストビューの行とセクションを再読み込み
        memoListView.reloadData()
    }
    
    //編集ボタン
    func onTapPencil(row: Int) {
        showAlert(IndexPath)
        updateAlert(UIAlertController, IndexPath)
    }
    
    // テーブルビューのセルをクリックしたら、アラートコントローラを表示する処理
    func showAlert(_ indexPath: IndexPath){
        let alertController: UIAlertController = UIAlertController(title: "編集", message: "チーム名の変更", preferredStyle: .alert)
        // アラートコントローラにテキストフィールドを表示 テキストフィールドには入力された情報を表示させておく処理
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
                                        // モデルクラスをインスタンス化
                                        let tableCell:MemoModel = MemoModel()
                                        textField.text = tableCell.memo})
        // アラートコントローラに"OK"ボタンを表示 "OK"ボタンをクリックした際に、テキストフィールドに入力した文字で更新する処理を実装
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) -> Void in self.updateAlert(alertController,indexPath)
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
            memoList[indexPath.row].memo = text
        }
        self.memoListView.reloadData()
    }
}

