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

    

    

    
    // Button部品をプロパティ名Confirm_Buttonで接続
    //確定ボタンがタップされたイベントでは、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    @IBAction func Confirm_Button(_ sender: Any) {
        applyMemo()
    }
    // TextField部品をプロパティ名TextFieldで接続
    @IBOutlet weak var TextField: UITextField!
    // Label部品をプロパティ名player_nameで接続
    @IBOutlet weak var player_name: UILabel!
    // TableView部品をプロパティ名memoListViewで接続
    @IBOutlet weak var memoListView: UITableView!
    
    //メモした内容を保持しておくString 配列 memoList
    //var 配列名:[値の型]
    var memoList: [String] = []
    //編集中の行番号を保持する editRow をメンバ変数として定義
    var editRow: Int = unselectedRow
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // メモ一覧で表示するセルを識別するIDの登録処理を追加。
        memoListView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        TextField.text = ""
    }
    
    //実行中のアプリがiPhoneのメモリを使いすぎた際に呼び出される。
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return memoList.count
        }

    //メモ一覧が表示する内容を返すメソッドでは30行目で宣言した memoList が保持している行番号に対応したメモを返すように実装。一応保持しているメモの数を超えていないことをチェック。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        if indexPath.row >= memoList.count {
            return cell
        }
        
        cell.textLabel?.text = memoList[indexPath.row]
                return cell
    }
    
    //メモ一覧のセルが選択されたイベントでは、選択されたメモを TextField に設定し、選択された行番号を32行目で宣言した editRow に保持。
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= memoList.count {
                    return
                }
                editRow = indexPath.row
                TextField.text = memoList[editRow]
    }
    
    //TextFieldで return(改行) されたイベントでは確定ボタンタップイベントと同様に、入力されたメモをメモ一覧へ反映するメソッドを呼び出すように実装。
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        applyMemo()
        return true
    }
    
    //メモの入力を確定するメソッドでは、追加モードか編集モードかを判定し、30行目で宣言した memoList に対して入力テキストの追加、または上書きを行い、 編集モードから追加モードへの変更、メモ一覧の更新を行うように実装。
    func applyMemo() {
        if TextField.text == nil {
                    return
                }
                
                if editRow == unselectedRow {
                    memoList.append(TextField.text!)
                } else {
                    memoList[editRow] = TextField.text!
                }
                //TextField の内容のクリア
                TextField.text = ""
                editRow = unselectedRow
                //メモリリストビューの行とセクションを再読み込み
                memoListView.reloadData()
    }
    

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }

    

}

