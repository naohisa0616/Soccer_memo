//
//  MatchModel.swift
//  Soccer_memo
//
//  Created by Junya Kengo on 2021/05/03.
//

import Foundation
import RealmSwift

//試合テーブル
class MatchModel: Object{
    @objc dynamic var id = 0 //試合ID
    @objc dynamic var matchResult: String? = "" //試合結果
    let player = List<PlayerModel>() //PlayerModelと1対多の関係
    
    //PrimaryKeyの設定
    func primaryKey() -> String? {
        return "id"
    }
    
    func create(text: String, finish: (()->())?) {
        // Realmインスタンス取得
        let realm = try! Realm()
        self.id = 0
        self.matchResult = text
        try! realm.write {
            realm.add(self)
            if let finish = finish {
                finish()
            }
        }
    }
}
