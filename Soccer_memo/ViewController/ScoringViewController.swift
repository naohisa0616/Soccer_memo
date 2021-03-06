//
//  ScoringViewControler.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/08.
//

import UIKit
import RealmSwift
import KMPlaceholderTextView

class ScoringViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    var player: PlayerModel!
    var playModel: Results<PlayerModel>!
    
    //遷移元から名前を取得用の変数を定義
    var dataInfo: String?
    var score: String?
    
    //ピッカービューの中身
    let compos = ["1点","2点","3点","4点","5点"] //5段階評価

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var playerInfo: UILabel!
    
    @IBOutlet weak var scoringPickerView: UIPickerView!
    
    //前半
    @IBOutlet weak var firstText: UITextView! 
    
    //後半
    @IBOutlet weak var LatterText: UITextView!
    
    //総評
    @IBOutlet weak var commeText: UITextView!
    
    override func viewDidLayoutSubviews() {

      scrollView.contentSize = contentView.frame.size
      scrollView.flashScrollIndicators()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        //タイトル名設定
        navigationItem.title = "選手採点"
        //ピッカービューのデリゲートになる。
        scoringPickerView.delegate = self
        //ピッカービューのデータソースになる。
        scoringPickerView.dataSource = self
        //選手名を取得
        self.playerInfo.text = dataInfo
        //キーボード下げるメソッド
        setDismissKeyboard()
        
        let realm = try! Realm()
        //選手ごとの採点結果の取得
        if let score = score {
            let playerPredicate = NSPredicate(format: "playerId == %d", score)
            self.playModel = realm.objects(PlayerModel.self).filter(playerPredicate)
        }
        
//        ["1点","2点","3点","4点","5点"]の何番目と同じ値かを検索する
        let index = compos.index(of: player.overallScore ?? "")
        if let index = index {
            // UIPickerViewの初期値を設定
            // 対応する配列の番号をselectRowに入れる
            scoringPickerView.selectRow(index, inComponent: 0, animated: false)
        }
       
    //前半の枠編集
        // 枠のカラー
        firstText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        firstText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        firstText.layer.cornerRadius = 20.0
        firstText.layer.masksToBounds = true
        firstText.delegate = self
        firstText.tag = 1
        
    //後半の枠編集
        // 枠のカラー
        LatterText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        LatterText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        LatterText.layer.cornerRadius = 20.0
        LatterText.layer.masksToBounds = true
        LatterText.delegate = self
        LatterText.tag = 2
        
    //総評の枠編集
        // 枠のカラー
        commeText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        commeText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        commeText.layer.cornerRadius = 20.0
        commeText.layer.masksToBounds = true
        commeText.delegate = self
        commeText.tag = 3
        
        // playerの値を入れてあげる
        firstText.text = player.firstInfo
        LatterText.text = player.latterInfo
        commeText.text = player.generalInfo
        
        // 保存したテキストの表示とプレースホルダー
        // 全部が入力されていない時の対応
        if firstText.text.isEmpty && LatterText.text.isEmpty && commeText.text.isEmpty {
            let firstText = KMPlaceholderTextView(frame: view.bounds)
            firstText.placeholder = "前半の良かったプレー、悪かったプレーなどを記入しよう！"
            let LatterText = KMPlaceholderTextView(frame: view.bounds)
            LatterText.placeholder = "後半の良かったプレー、悪かったプレーなどを記入しよう！"
            let commeText = KMPlaceholderTextView(frame: view.bounds)
            commeText.placeholder = "試合を通しての感想や総合的な評価などを記入しよう！"
        }

    }
    
    //ピッカービューのコンポーネントの列数を返す。
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //各コンポーネントの行数を返す。
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //値の個数が行数になる
        return compos.count
    }
    
    //データを返すメソッド、UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,forComponent component: Int, reusing view: UIView?) -> UIView{
        let label = UILabel()
        // 中央寄せ
        label.textAlignment = NSTextAlignment.center
        label.text = compos[row]
        return label
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let label = UILabel()
        label.text = compos[row]
        let string = String(label.text!)
        // Realmにデータを保存
        let realm = try! Realm()
        try! realm.write{
            player.overallScore = string
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         return true
     }

    //プレースホルダーの実装
    //テキストビューの編集が開始されたときにデリゲートに通知
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "テキストの入力" {
            textView.text = nil
            textView.textColor = .darkText
        }
    }
    
    //テキストビューの編集が終了したときにデリゲートに通知
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            //セルの削除処理
            let realm = try! Realm()
            
            switch textView.tag {
                case (1):
                    // データを削除（前半）
                    try! realm.write {
                        player.firstInfo = ""
                    }
                case (2):
                    // データを削除（後半）
                    try! realm.write {
                        player.latterInfo = ""
                    }
                case (3):
                    // データを削除（総評）
                    try! realm.write {
                        player.generalInfo = ""
                    }
            default:
                print("textの削除は失敗")
            }
        } else {
            let realm = try! Realm()
        
            switch textView.tag {
                case (1):
                    // Realmにデータを保存（前半）
                    try! realm.write{
                        player.firstInfo = self.firstText.text!
                    }
                case (2):
                    // Realmにデータを保存（後半）
                    try! realm.write{
                        player.latterInfo = self.LatterText.text!
                    }
                case (3):
                    // Realmにデータを保存（総評）
                    try! realm.write{
                        player.generalInfo = self.commeText.text!
                    }
            default:
                print("textの保存は失敗")
            }
        }
    }
}

// MARK: UIViewController
extension UIViewController {
    
    func setDismissKeyboard() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
