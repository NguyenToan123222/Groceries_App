//
//  ExploreCategoryModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.

import SwiftUI

struct ExploreCategoryModel: Identifiable, Equatable {
    var id: Int
    var name: String
    var image: String
    var color: Color
    
    init(dict: NSDictionary) {
        self.id = dict["cat_id"] as? Int ?? 0
        self.name = dict["cat_name"] as? String ?? ""
        self.image = dict["image"] as? String ?? ""
        let colorHex = dict["color"] as? String ?? "53B175" // Mặc định màu xanh lá nếu không có
        self.color = Color(hex: colorHex)
    }
}

