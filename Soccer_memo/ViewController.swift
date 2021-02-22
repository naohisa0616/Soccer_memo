//
//  ViewController.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/01/02.
//

import UIKit

private let unselectedRow = -1

//クラス定義に UITextFieldDelegate プロトコルを追加。（子クラス名: 親クラス名）
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Button部品をプロパティ名confirm_Buttonで接続
    //確定ボタンがタップされたイベントでは、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    @IBAction func confirmButton(_ sender: Any) {
        applyMemo()
    }
    @IBOutlet weak var buttonEnabled: UIButton!
    // TextField部品をプロパティ名textFieldで接続
    @IBOutlet weak var textField: UITextField!
    // Label部品をプロパティ名player_nameで接続
    @IBOutlet weak var player_name: UILabel!
    // TableView部品をプロパティ名memoListViewで接続
    @IBOutlet weak var memoListView: UITableView!
    //画面タップでキーボードを下げる
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        //編集終了でキーボードを下げる
        view.endEditing(true)
    }
    //メモした内容を保持しておくString配列memoList
    //var 配列名:[値の型]（空の配列）
    var memoList: [String] = []
    //編集中の行番号を保持する editRow をメンバ変数として定義
    var editRow: Int = unselectedRow
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //テーブルビューのデリゲートを設定する。
        self.memoListView.delegate = self
        //テーブルビューのデータソースを設定する。
        self.memoListView.dataSource = self
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        memoListView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        textField.text = ""
        buttonEnabled.isEnabled = false
        textField.addTarget(self, action:#selector(textFieldDidChange),for: UIControl.Event.editingChanged)
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
        return memoList.count
    }
    
    //メモ一覧が表示する内容を返すメソッドでは宣言したmemoListが保持している行番号に対応したメモを返すように実装。保持しているメモの数を超えていないことをチェック。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        if indexPath.row >= memoList.count {
            return cell
        }
        cell.textLabel?.text = memoList[indexPath.row]
        return cell
    }
    
    //メモ一覧のセルが選択されたイベントでは、選択されたメモを TextFieldに設定し、選択された行番号で宣言したeditRowに保持。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= memoList.count {
            return
        }
        editRow = indexPath.row
        textField.text = memoList[editRow]
    }
    
    //TextFieldでreturn(改行)されたイベントでは確定ボタンタップイベントと同様に、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyMemo()
        return true
    }
    
    //メモの入力を確定するメソッドでは、追加モードか編集モードかを判定し、memoListに対して入力テキストの追加、または上書きを行い、 編集モードから追加モードへの変更、メモ一覧の更新を行うように実装。
    func applyMemo() {
        if textField.text == nil {
            return
        }
        
        if editRow == unselectedRow {
            //メモにテキストに入力された値を追加する
            memoList.append(textField.text!)
        } else {
            memoList[editRow] = textField.text!
        }
        //TextField の内容のクリア
        textField.text = ""
        buttonEnabled.isEnabled = false
        editRow = unselectedRow
        //メモリリストビューの行とセクションを再読み込み
        memoListView.reloadData()
    }
    
    //TableViewCellの削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データソースから行を削除する。
            self.memoList.remove(at: indexPath.row)
            // TableViewを削除する操作
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

