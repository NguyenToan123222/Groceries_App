//
//  AdminOrderDetailViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/4/25.
// AdminOrderDetailViewModel.swift
import SwiftUI

class AdminOrderDetailViewModel: ObservableObject {
    @Published var pObj: MyOrderModel
    @Published var listArr: [OrderItemModel] = []
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var statuses: [String] = []

    init(prodObj: MyOrderModel) {
        self.pObj = prodObj
        fetchStatuses()
        serviceCallDetail()
    }

    func fetchStatuses() {
        let path = "\(Globs.BASE_URL)orders/admin/statuses"
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? [String] {
                DispatchQueue.main.async {
                    self.statuses = response
                }
            }
        } failure: { _ in }
    }

    func serviceCallDetail() {
        let path = "\(Globs.SV_MY_ORDERS_DETAIL)\(self.pObj.id)"
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                DispatchQueue.main.async {
                    self.pObj = MyOrderModel(dict: response)
                    self.listArr = (response["items"] as? [NSDictionary] ?? []).map { OrderItemModel(dict: $0) }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch order details"
                    self.showError = true
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }

    func updateOrderStatus(newStatus: String) {
        let path = "\(Globs.BASE_URL)orders/admin/\(pObj.id)/status?newStatus=\(newStatus)"
        ServiceCall.put(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    self.successMessage = response
                    self.showSuccess = true
                    self.serviceCallDetail()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update order status"
                    self.showError = true
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }

    func completeCODPayment() {
        let path = "\(Globs.BASE_URL)orders/customer/\(pObj.id)/complete-cod"
        ServiceCall.post(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    self.successMessage = response
                    self.showSuccess = true
                    self.serviceCallDetail()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to complete COD payment"
                    self.showError = true
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }
}
