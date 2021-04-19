//
//  MemoModel.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/27.
//

import Foundation
import RealmSwift
import UIKit

//チームテーブル
class MemoModel: Object{
  static let realm = try! Realm()
    
  let match = List<MatchModel>() //MatchModelと1対多の関係
  
  @objc dynamic private var teamId = 0 //チームID
  @objc dynamic var memo: String? = "" //チーム名
  @objc dynamic private var photo: NSData? = nil //チーム画像
  @objc dynamic private var _image: UIImage? = nil
  @objc dynamic var image: UIImage? {
            //setter
            set{
                self._image = newValue
                if let value = newValue {
                    self.photo = value.pngData() as NSData?
                }
            }
            //getter
            get{
                if let image = self._image {
                    return image
                }
                if let data = self.photo {
                    self._image = UIImage(data: data as Data)
                    return self._image
                }
                return nil
            }
  }
    
        //PrimaryKeyの設定
        override static func primaryKey() -> String? {
            return "teamId"
        }

        override static func ignoredProperties() -> [String] {
            return ["image", "_image"]
        }

        static func create() -> MemoModel {
            let user = MemoModel()
            user.teamId = lastId()
            return user
        }

        static func loadAll() -> [MemoModel] {
            let users = realm.objects(MemoModel.self).sorted(byKeyPath: "id", ascending: false)
            var ret: [MemoModel] = []
            for user in users {
                ret.append(user)
            }
            return ret
        }

        static func lastId() -> Int {
            if let user = realm.objects(MemoModel.self).last {
                return user.teamId + 1
            } else {
                return 1
            }
        }

        func save() {
            try! MemoModel.realm.write {
                MemoModel.realm.add(self)
            }
        }

}

//試合テーブル
class MatchModel: Object{
    @objc dynamic private var matchId = 0 //試合ID
    @objc dynamic var matchResult: String? = "" //試合結果
    let player = List<PlayerModel>() //PlayerModelと1対多の関係
    
    //PrimaryKeyの設定
    func primaryKey() -> String? {
        return "matchId"
    }
}

//選手テーブル
class PlayerModel: Object{
    @objc dynamic private var playerId = 0 //選手ID
    @objc dynamic var overallScore = 0 //総評点
    @objc dynamic var info: String? = "" //総評情報
    @objc dynamic var playername: String? = "" //選手名
    
    //PrimaryKeyの設定
    func primaryKey() -> String? {
        return "playerId"
    }
}


