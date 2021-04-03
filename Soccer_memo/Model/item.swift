//
//  item.swift
//  Soccer_memo
//
//  Created by Junya Kengo on 2021/03/30.
//

import Foundation

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
