//
//  MyOrderModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.


// MyOrderModel.swift
import SwiftUI

struct MyOrderModel: Identifiable, Equatable {
    var id: Int = 0 // Sử dụng id từ OrderDTO
    var orderCode: String = "" // Thêm orderCode
    var totalPrice: Double = 0.0
    var status: String = "" // Trạng thái đơn hàng: PENDING, COMPLETED, CANCELLED, AWAITING_PICKUP
    var paymentMethod: String = "" // Phương thức thanh toán: MOMO, PAYPAL, COD
    var isPaid: Bool = false // Trạng thái thanh toán
    var createdDate: Date = Date()
    var items: [OrderItemModel] = [] // Danh sách sản phẩm trong đơn hàng
    var street: String = ""
    var province: String = ""
    var district: String = ""
    var ward: String = ""

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.orderCode = dict.value(forKey: "orderCode") as? String ?? ""
        self.totalPrice = dict.value(forKey: "totalPrice") as? Double ?? 0.0
        self.status = dict.value(forKey: "status") as? String ?? ""
        self.paymentMethod = dict.value(forKey: "paymentMethod") as? String ?? ""
        self.isPaid = dict.value(forKey: "isPaid") as? Bool ?? false
        self.createdDate = (dict.value(forKey: "createdAt") as? String ?? "").iso8601toDate() ?? Date()
        self.items = (dict.value(forKey: "items") as? NSArray ?? []).map { OrderItemModel(dict: $0 as? NSDictionary ?? [:]) }
        self.street = dict.value(forKey: "street") as? String ?? ""
        self.province = dict.value(forKey: "province") as? String ?? ""
        self.district = dict.value(forKey: "district") as? String ?? ""
        self.ward = dict.value(forKey: "ward") as? String ?? ""
    }

    static func == (lhs: MyOrderModel, rhs: MyOrderModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// Extension để chuyển đổi chuỗi ISO 8601 thành Date
extension String {
    func iso8601toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}
