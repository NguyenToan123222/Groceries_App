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
    var color: String
    var assetImageName: String? // Tên hình ảnh từ Assets
    
    init(dict: NSDictionary) {
        self.id = dict["cat_id"] as? Int ?? 0
        self.name = dict["cat_name"] as? String ?? ""
        self.image = dict["image"] as? String ?? ""
        self.color = dict["color"] as? String ?? "53B175" // Lưu trực tiếp chuỗi hex
        self.assetImageName = dict["assetImageName"] as? String // Hình ảnh từ Assets (nếu có)
    }
}

