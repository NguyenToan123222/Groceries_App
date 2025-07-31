//
//  CategoryModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 28/3/25.
//

import SwiftUI


struct CategoryModel: Identifiable {
    let id: Int
    let name: String

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.name = dict.value(forKey: "name") as? String ?? ""
    }
}
