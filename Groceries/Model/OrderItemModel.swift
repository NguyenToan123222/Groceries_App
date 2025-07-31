//
//  OrderItemModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.


// OrderItemModel.swift
import SwiftUI

struct OrderItemModel: Identifiable, Equatable {
    var id: UUID = UUID() // có thể thay đổi giá trị và được gán lại (ví dụ: lấy từ API hoặc gán giá trị khác nếu cần).
    var productId: Int = 0
    var productName: String = ""
    var quantity: Int = 0
    var price: Double = 0.0
    var rating: Float// Giữ lại để hỗ trợ review sau này
    let imageUrl: String?

    init(dict: NSDictionary) {
        self.productId = dict.value(forKey: "productId") as? Int ?? 0
        self.productName = dict.value(forKey: "productName") as? String ?? ""
        self.quantity = dict.value(forKey: "quantity") as? Int ?? 0
        self.price = dict.value(forKey: "price") as? Double ?? 0.0
        self.imageUrl = dict["imageUrl"] as? String
        self.rating = dict["rating"] as? Float ?? 0.0
    }

    static func == (lhs: OrderItemModel, rhs: OrderItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
