//
//  CartItemModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.


import SwiftUI

struct CartItemModel: Identifiable, Equatable {
    var id: Int?
    var productId: Int?
    var productName: String
    var quantity: Int
    var imageUrl: String
    var price: Double
    var totalPrice: Double
    var discountPercentage: Double?
    var originalPrice: Double?
    var startDate: Date?
    var endDate: Date?
    var isDiscountValid: Bool

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int
        self.productId = dict.value(forKey: "productId") as? Int
        self.productName = dict.value(forKey: "productName") as? String ?? ""
        self.quantity = dict.value(forKey: "quantity") as? Int ?? 0
        self.imageUrl = dict.value(forKey: "imageUrl") as? String ?? ""
        self.price = dict.value(forKey: "price") as? Double ?? 0.0
        self.totalPrice = dict.value(forKey: "totalPrice") as? Double ?? 0.0
        self.discountPercentage = dict.value(forKey: "discountPercentage") as? Double
        self.originalPrice = dict.value(forKey: "originalPrice") as? Double
        self.startDate = (dict.value(forKey: "startDate") as? String)?.iso8601Date()
        self.endDate = (dict.value(forKey: "endDate") as? String)?.iso8601Date()

        let currentDate = Date()
        if startDate != nil && endDate != nil {
            self.isDiscountValid = (self.discountPercentage != nil && self.price < (self.originalPrice ?? self.price)) && (startDate! <= currentDate && currentDate <= endDate!)
        } else {
            self.isDiscountValid = (self.discountPercentage != nil && self.price < (self.originalPrice ?? self.price))
        }
        //Khối if kiểm tra cả giá và thời gian, trong khi khối else chỉ kiểm tra giá nếu thiếu thời gian.
    }

    static func == (lhs: CartItemModel, rhs: CartItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
