//
//  MyOrderDetailViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.
//
// MyOrderDetailViewModel.swift
import SwiftUI

class MyOrderDetailViewModel: ObservableObject {
    @Published var pObj: MyOrderModel
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var listArr: [OrderItemModel] = []
    
    init(prodObj: MyOrderModel) {
        self.pObj = prodObj
        serviceCallDetail()
        // Khi người dùng nhấn vào đơn #123 trong màn hình "My Orders", prodObj là thông tin đơn #123 từ danh sách.
    }
    
    // MARK: Service Call
    func serviceCallDetail() {
        ServiceCall.get(path: Globs.SV_MY_ORDERS_DETAIL + "\(self.pObj.id)", withSuccess: { responseObj in
            if let response = responseObj as? NSDictionary {
                do {
                    self.pObj = MyOrderModel(dict: response)
                    /*
                     response = ["id": 123, "date": "2025-03-20", "total": 50.0, "status": "Pending"].
                     pObj = MyOrderModel(id: 123, date: "2025-03-20", total: 50.0, status: "Pending").
                     */
                    self.listArr = (response.value(forKey: "items") as? [NSDictionary] ?? []).map { OrderItemModel(dict: $0) }
                    /*
                     - response.value(forKey: "items"): Lấy giá trị của key "items" (mảng các mặt hàng).
                     - as? [NSDictionary]: Ép thành mảng [NSDictionary].
                     - ?? []: Nếu ép thất bại hoặc không có "items", dùng mảng rỗng.
                     - .map { OrderItemModel(dict: $0) }: Chuyển mỗi NSDictionary thành OrderItemModel.
                     - self.listArr: Gán danh sách mặt hàng vào @Published var listArr.
                     - response["items"] = [{"productId": 456, "name": "Táo", "quantity": 2, "price": 10.0}, {"productId": 459, "name": "Dứa", "quantity": 1, "price": 30.0}].
                     - listArr = [OrderItemModel(productId: 456, name: "Táo", ...), OrderItemModel(productId: 459, name: "Dứa", ...)].
                     */
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse order details: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response format for order details"
                    self.showError = true
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to fetch order details"
                self.showError = true
            }
        })
    }
    
    func cancelOrder() {
        let parameters = NSDictionary(dictionary: [:])
        ServiceCall.post(parameter: parameters, path: Globs.SV_MY_ORDERS_DETAIL + "\(self.pObj.id)", withSuccess: { responseObj in
            if let response = responseObj as? String { // Order cancelled successfully
                DispatchQueue.main.async {
                    self.errorMessage = response
                    self.showError = true
                    self.serviceCallDetail() // Cập nhật lại chi tiết đơn hàng sau khi hủy
                }
            } else if let response = responseObj as? NSDictionary { // ["message": "Order cannot be cancelled"]
                if let message = response["message"] as? String {
                    DispatchQueue.main.async {
                        self.errorMessage = message
                        self.showError = true
                        self.serviceCallDetail()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse cancellation response"
                        self.showError = true
                    }
                }
            } else { // Sai định dạng
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response format"
                    self.showError = true
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to cancel order"
                self.showError = true
            }
        })
    }}
