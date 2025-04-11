//
//  CartItemModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.


import SwiftUI

struct CartItemModel: Identifiable, Equatable {
    var id: Int? // Khớp với id từ CartDTO
    var productId: Int? // Thêm productId
    var productName: String
    var quantity: Int
    var imageUrl: String // Khớp với imageUrl từ CartDTO
    var price: Double
    var totalPrice: Double

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.productId = dict["productId"] as? Int ?? 0 // Lấy productId từ response
        self.productName = dict.value(forKey: "productName") as? String ?? "Unknown Product"
        self.quantity = dict.value(forKey: "quantity") as? Int ?? 0
        self.imageUrl = dict.value(forKey: "imageUrl") as? String ?? ""
        self.price = dict.value(forKey: "price") as? Double ?? 0.0
        self.totalPrice = dict.value(forKey: "totalPrice") as? Double ?? 0.0
    }

    static func == (lhs: CartItemModel, rhs: CartItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
