//
//  AdminOrdersViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/4/25.
//

import SwiftUI

class AdminOrdersViewModel: ObservableObject {
    
    @Published var orders: [MyOrderModel] = []
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var currentPage = 0
    @Published var isLoadingMore = false
    @Published var canLoadMore = true
    
    @Published var statistics: [String: Any] = [:]
    @Published var statuses: [String] = []
    private let pageSize = 10

    init() {
        fetchStatuses()
        fetchStatistics()
        fetchOrders()
    }

    private func resetAlerts() {
        showError = false
        showSuccess = false
        errorMessage = ""
        successMessage = ""
    }

    func fetchOrders(status: String? = nil, isRefresh: Bool = false) {
        if isLoadingMore { return } // stop stack call api

        if isRefresh {
            currentPage = 0
            canLoadMore = true
            orders.removeAll()
        }

        let pageToLoad = currentPage
        isLoadingMore = true

        var urlString = "\(Globs.BASE_URL)orders/admin/all"
        var queryItems: [String: String] = ["page": "\(pageToLoad)", "size": "\(pageSize)"] // queryItems = ["page": "1", "size": "10"]
        if let status = status {
            queryItems["status"] = status // // queryItems = ["page": "1", "size": "10", "status": "pending"]
        }

        let queryString = queryItems.map { "\($0.key)=\($0.value)" }.joined(separator: "&") // queryString = "page=1&size=10&status=pending"
        if !queryString.isEmpty {
            urlString += "?\(queryString)" // add ?
        }
        print("Calling API: \(urlString)") // Thêm log để kiểm tra URL
        // urlString = "https://api.example.com/orders/admin/all?page=1&size=10&status=pending"
        ServiceCall.get(path: urlString) { responseObj in
            print("API Response for \(urlString): \(responseObj)") // Thêm log để kiểm tra phản hồi
            if let response = responseObj as? NSDictionary,
               let content = response["content"] as? [NSDictionary] {
                let newOrders = content.map { MyOrderModel(dict: $0) }
                DispatchQueue.main.async {
                    if isRefresh {
                        self.orders = newOrders// renew
                    } else {
                        self.orders.append(contentsOf: newOrders) // load more
                    }
                    self.currentPage = pageToLoad + 1
                    self.canLoadMore = newOrders.count == self.pageSize
                    self.isLoadingMore = false
                } //DispatchQueue
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch orders"
                    self.showError = true
                    self.isLoadingMore = false
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                self.isLoadingMore = false
            }
        }
    }
/*
 {
     "status": "success",
     "content": [
         {"id": 1, "status": "pending", "total": 59.98},
         {"id": 2, "status": "pending", "total": 19.99}
     ]
 }
 */
    func fetchStatistics() {
        resetAlerts()
        let path = "\(Globs.BASE_URL)orders/admin/statistics"
        
        ServiceCall.get(path: path) { responseObj in
            print("Statistics API Response: \(responseObj)") // Thêm log để kiểm tra
            if let response = responseObj as? [String: Any] {
                DispatchQueue.main.async {
                    self.statistics = response
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch statistics"
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

    func fetchStatuses() {
        resetAlerts()
        let path = "\(Globs.BASE_URL)orders/admin/statuses"
        
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? [String] {
                DispatchQueue.main.async {
                    self.statuses = response
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch order statuses"
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

    func updateOrderStatus(orderId: Int, newStatus: String, completion: @escaping (Bool) -> Void) {
        resetAlerts()
        let path = "\(Globs.BASE_URL)orders/admin/\(orderId)/status?newStatus=\(newStatus)"
        print("Calling API: \(path)") // Thêm log
        ServiceCall.put(parameter: [:], path: path) { responseObj in
            print("Update Status Response: \(responseObj)") // Thêm log
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    self.successMessage = response
                    self.showSuccess = true
                    self.fetchOrders(isRefresh: true)
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update order status"
                    self.showError = true
                    completion(false)
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                completion(false)
            }
        }
    }

    func completeCODPayment(orderId: Int, completion: @escaping (Bool) -> Void) {
        resetAlerts()
        let path = "\(Globs.BASE_URL)orders/admin/\(orderId)/complete-cod"
        print("Calling API: \(path)") // Thêm log để kiểm tra URL
        ServiceCall.post(parameter: [:], path: path) { responseObj in
            print("Complete COD Payment Response: \(responseObj)") // Thêm log để kiểm tra phản hồi
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    self.successMessage = response
                    self.showSuccess = true
                    self.fetchOrders(isRefresh: true)
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to complete COD payment"
                    self.showError = true
                    completion(false)
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                completion(false)
            }
        }
    }

    func loadMoreIfNeeded(currentItem: MyOrderModel?) {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = orders.count - 1
        if orders.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex && canLoadMore && !isLoadingMore {
            fetchOrders()
        }
    }

    func refreshOrders() {
        fetchOrders(isRefresh: true)
    }
}
