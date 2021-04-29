//
//  ScoringViewControler.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/08.
//

import UIKit
import RealmSwift

class ScoringViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var player: Results<PlayerModel>!
    
    //遷移元から名前を取得用の変数を定義
    var dataInfo: String?
    
    //ピッカービューの中身
    let compos = ["1点","2点","3点","4点","5点"] //5段階評価

    @IBOutlet weak var playerInfo: UILabel!
    
    @IBOutlet weak var scoringPickerView: UIPickerView!
    
    //前半
    @IBOutlet weak var firstText: UITextView!
    
    //後半
    @IBOutlet weak var LatterText: UITextView!
    
    //総評
    @IBOutlet weak var commeText: UITextView!
    
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
       
    //前半の枠編集
        // 枠のカラー
        firstText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        firstText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        firstText.layer.cornerRadius = 20.0
        firstText.layer.masksToBounds = true
        
    //後半の枠編集
        // 枠のカラー
        LatterText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        LatterText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        LatterText.layer.cornerRadius = 20.0
        LatterText.layer.masksToBounds = true
        
    //総評の枠編集
        // 枠のカラー
        commeText.layer.borderColor = UIColor.blue.cgColor
        
        // 枠の幅
        commeText.layer.borderWidth = 2.0
        
        // 枠を角丸にする
        commeText.layer.cornerRadius = 20.0
        commeText.layer.masksToBounds = true

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
        // Realmにデータを保存
        let realm = try! Realm()
        try! realm.write{
            player.overallScore = label.text
        }
        
    }
    

}
