//
//  PaymentMode.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 18/3/25.


import SwiftUI

struct PaymentModel: Identifiable, Equatable {
    var id: String // transactionId từ BE
    var orderId: Int
    var paymentMethod: String // "PAYPAL", "MOMO", "COD"
    var status: String // "PENDING", "COMPLETED", "FAILED"
    var paymentUrl: String? // URL để chuyển hướng thanh toán (PayPal/MoMo)

    init(id: String = "", orderId: Int = 0, paymentMethod: String = "", status: String = "PENDING", paymentUrl: String? = nil) {
        self.id = id
        self.orderId = orderId
        self.paymentMethod = paymentMethod
        self.status = status
        self.paymentUrl = paymentUrl
    }

    // Parse từ response của API createPayment
    init(dict: NSDictionary, orderId: Int, paymentMethod: String) {
        self.id = UUID().uuidString // Tạm thời tạo ID phía FE
        self.orderId = orderId
        self.paymentMethod = paymentMethod
        self.status = "PENDING"
        self.paymentUrl = dict.value(forKey: "paymentUrl") as? String ?? ""
    }

    static func == (lhs: PaymentModel, rhs: PaymentModel) -> Bool {
        return lhs.id == rhs.id
    }
}
