//
//  MyOrdersViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.

// MyOrdersViewModel.swift
import SwiftUI

class MyOrdersViewModel: ObservableObject {
    static var shared: MyOrdersViewModel = MyOrdersViewModel()

    @Published var showError = false
    @Published var errorMessage = ""
    @Published var listArr: [MyOrderModel] = []
    @Published var currentPage = 0 // Trang hiện tại (bắt đầu từ 0).
    @Published var isLoadingMore = false // Trạng thái đang tải dữ liệu (tránh gọi API trùng lặp).
    @Published var canLoadMore = true // Có còn đơn hàng để tải không.
    private let pageSize = 5 // Số đơn hàng mỗi trang (cố định).

    init() {
        serviceCallList()
    }

    // MARK: Service Call
    func serviceCallList(status: String? = nil, page: Int? = nil, isRefresh: Bool = false) {
        if isLoadingMore { return } // Tránh gọi API trùng lặp khi đang tải

        if isRefresh {
            currentPage = 0 // Reset về trang đầu khi làm mới
            canLoadMore = true
            listArr.removeAll() // Xóa danh sách cũ
        }

        let pageToLoad = page ?? currentPage
        isLoadingMore = true // sẽ ngăn gọi API mới cho đến khi trang 0 tải xong.

        var urlString = Globs.SV_MY_ORDERS_LIST
        var queryItems: [String: String] = ["page": "\(pageToLoad)", "size": "\(pageSize)"]
        if let status = status { // Nếu status không phải nil, thêm tham số status vào queryItems
            queryItems["status"] = status // ["page": "0", "size": "5", "status": "pending"]
        }
        /*
         Giả sử Globs.SV_MY_ORDERS_LIST = "https://api.groceries.com/orders".
         Nếu gọi serviceCallList(status: "delivered", page: 1):
         pageToLoad = 1, pageSize = 5, status = "delivered".
         queryItems = ["page": "1", "size": "5", "status": "delivered"].
         */

        let queryString = queryItems.map { "\($0.key)=\($0.value)" }.joined(separator: "&")// page=1&size=5&status=delivered
        if !queryString.isEmpty {
            urlString += "?\(queryString)" // https://api.groceries.com/orders?page=1&size=5&status=delivered
        }

        ServiceCall.get(path: urlString, withSuccess: { responseObj in
            if let response = responseObj as? NSDictionary {
                if let content = response.value(forKey: "content") as? [NSDictionary] {
                    let newOrders = content.map { MyOrderModel(dict: $0) }
                    if isRefresh {
                        self.listArr = newOrders // Thay thế danh sách cũ
                    } else {
                        self.listArr.append(contentsOf: newOrders) // Thêm vào danh sách hiện tại
                    }
                    /*
                     Nếu isRefresh = true: Thay thế hoàn toàn listArr bằng newOrders (làm mới danh sách).
                     Nếu isRefresh = false: Thêm newOrders vào cuối listArr (tải thêm dữ liệu).
                     */
                    self.currentPage = pageToLoad + 1
                    self.canLoadMore = newOrders.count == self.pageSize // Nếu số lượng trả về nhỏ hơn pageSize, không còn dữ liệu để tải
                } else {
                    self.errorMessage = response.value(forKey: "message") as? String ?? "Failed to fetch orders"
                    self.showError = true
                }
            }
            self.isLoadingMore = false
        }, failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Failed to fetch orders"
            self.showError = true
            self.isLoadingMore = false
        })
    }

    // Hàm để làm mới danh sách (gọi sau khi đặt hàng)
    func refreshOrders() {
        serviceCallList(isRefresh: true)
    }

    // Hàm để tải thêm dữ liệu
    func loadMoreIfNeeded(currentItem: MyOrderModel?) {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = listArr.count - 1
        if listArr.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex && canLoadMore && !isLoadingMore {
            serviceCallList()
        }
    }
}
