//
//  MemoModel.swift
//  Soccer_memo
//
//  Created by 宮崎直久 on 2021/03/27.
//

import Foundation
import RealmSwift

class MemoModel: Object{
  @objc dynamic var memo: String? = ""
  @objc dynamic var context = ""
  @objc dynamic var score = ""
  @objc dynamic var photo: NSData? = nil
}


