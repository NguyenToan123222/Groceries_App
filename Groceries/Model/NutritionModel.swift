//
//  NutritionModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI

struct NutritionModel: Identifiable {
    let id: Int
    let name: String
    let unit: String // Thêm thuộc tính unit

    init(dict: NSDictionary) {
        self.id = dict["id"] as? Int ?? 0
        self.name = dict["name"] as? String ?? ""
        self.unit = dict["unit"] as? String ?? "g" // Mặc định là "g" nếu không có
    }
    static func == (lhs: NutritionModel, rsh: NutritionModel) -> Bool {
        return lhs.id == rsh.id
    }
}
