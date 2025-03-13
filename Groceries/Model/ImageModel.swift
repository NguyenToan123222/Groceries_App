//
//  SwiftUIView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI

struct ImageModel : Identifiable, Equatable {
     
    var id: Int = 0
    var proId: Int = 0
    var image: String = ""
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "img_id") as? Int ??  0
        self.image = dict.value(forKey: "image") as? String ?? ""
        self.proId = dict.value(forKey: "prod_id") as? Int ?? 0
    }
    static func == (lhs: ImageModel, rsh: ImageModel) -> Bool {
        return lhs.id == rsh.id
    }
}
