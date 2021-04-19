//
//  ViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/01/02.
//

import UIKit
import RealmSwift

private let unselectedRow = -1

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath as IndexPath)
        if indexPath.row >= memoList.count {
            return cell
        }
        cell.textLabel?.text = memoList[indexPath.row].memo
        return cell
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
    
    //セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // Realmインスタンス取得
            let realm = try! Realm()
            // データを削除
            try! realm.write {
                realm.delete(memoList[indexPath.row])
            }
            memoListView.reloadData()
        }
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
}

