//
//  CartViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.
//

import SwiftUI

class CartViewModel: ObservableObject {
    static var shared: CartViewModel = CartViewModel()

    @Published var showError = false
    @Published var errorMessage = ""
    @Published var listArr: [CartItemModel] = []
    @Published var total: String = "0.0"

    // Lấy userId từ hệ thống
    private var userId: Int {
        return Utils.UDValue(key: "userId") as? Int ?? 1
    }

    init() {
        serviceCallList()
    }

    // Lấy danh sách giỏ hàng
    func serviceCallList() {
        let path = "\(Globs.SV_CART_LIST)?userId=\(userId)"
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                print("Cart API Response: \(response)") // Debug dữ liệu
                if let items = response["items"] as? NSArray {
                    // Cập nhật listArr
                    let newItems = items.map { CartItemModel(dict: $0 as? NSDictionary ?? [:]) }
                    DispatchQueue.main.async {
                        self.listArr = newItems
                        // Tính lại total dựa trên listArr
                        let calculatedTotal = newItems.reduce(0.0) { $0 + $1.totalPrice }
                        self.total = String(format: "%.2f", calculatedTotal)
                        print("Calculated Total: \(self.total)") // Debug total
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load cart items"
                        self.showError = true
                        self.listArr = []
                        self.total = "0.0"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response format"
                    self.showError = true
                    self.listArr = []
                    self.total = "0.0"
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to load cart"
                self.showError = true
                self.listArr = []
                self.total = "0.0"
            }
        }
    }
        
    // Thêm sản phẩm vào giỏ hàng
    func serviceCallAddToCart(prodId: Int, qty: Int, completion: @escaping (Bool, String) -> Void) {
        let path = "\(Globs.SV_ADD_CART)?userId=\(userId)&productId=\(prodId)&quantity=\(qty)"
        ServiceCall.post(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    DispatchQueue.main.async {
                        self.serviceCallList() // Làm mới danh sách
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to add to cart: Invalid response"
                        self.showError = true
                    }
                    completion(false, "Failed to add to cart: Invalid response")
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to add to cart"
                self.showError = true
            }
            completion(false, self.errorMessage)
        }
    }
    
    // Thêm nhiều sản phẩm vào giỏ hàng
    func addMultipleToCart(products: [ProductModel], completion: @escaping (Bool, String) -> Void) {
        guard !products.isEmpty else {
            completion(false, "No products to add to cart.")
            return
        }
        
        var successCount = 0
        var errorMessages: [String] = []
        let totalCount = products.count
        
        // Sử dụng DispatchGroup để theo dõi các tác vụ bất đồng bộ
        let dispatchGroup = DispatchGroup()
        
        for product in products {
            dispatchGroup.enter()
            serviceCallAddToCart(prodId: product.id, qty: 1) { success, message in
                if success {
                    successCount += 1
                } else {
                    errorMessages.append("Failed to add \(product.name): \(message)")
                }
                dispatchGroup.leave()
            }
        }
        
        // Khi tất cả các tác vụ hoàn tất
        dispatchGroup.notify(queue: .main) {
            if successCount == totalCount {
                completion(true, "All items added to cart successfully.")
            } else if successCount > 0 {
                completion(true, "Added \(successCount)/\(totalCount) items. Errors: \(errorMessages.joined(separator: "; "))")
            } else {
                completion(false, "Failed to add items to cart: \(errorMessages.joined(separator: "; "))")
            }
        }
    }
        
    // Cập nhật số lượng sản phẩm trong giỏ hàng
    func serviceCallUpdateQty(cObj: CartItemModel, newQty: Int, completion: @escaping (Bool, String) -> Void) {
        guard let productId = cObj.productId else {
            self.errorMessage = "Invalid product ID"
            self.showError = true
            completion(false, "Invalid product ID")
            return
        }

        let path = "\(Globs.SV_UPDATE_CART)?userId=\(userId)&productId=\(productId)&quantity=\(newQty)"
        
        ServiceCall.put(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    DispatchQueue.main.async {
                        // Tìm và cập nhật item trong listArr
                        if let index = self.listArr.firstIndex(where: { $0.productId == productId }) {
                            // Cập nhật quantity và totalPrice
                            self.listArr[index].quantity = newQty
                            self.listArr[index].totalPrice = Double(newQty) * self.listArr[index].price
                            // Gán lại listArr để kích hoạt làm mới giao diện
                            self.listArr = self.listArr
                            // Cập nhật total
                            let calculatedTotal = self.listArr.reduce(0.0) { $0 + $1.totalPrice }
                            self.total = String(format: "%.2f", calculatedTotal)
                            print("Updated Total after qty change: \(self.total)") // Debug total
                        }
                    
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to update quantity: Invalid response"
                        self.showError = true
                        completion(false, "Failed to update quantity: Invalid response")
                    }
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to update quantity"
                self.showError = true
                completion(false, self.errorMessage)
            }
        }
    }
    
    // Xóa sản phẩm khỏi giỏ hàng
    func serviceCallRemove(cObj: CartItemModel, completion: @escaping (Bool, String) -> Void) {
        guard let productId = cObj.productId else { // Sử dụng productId thay vì id
            self.errorMessage = "Invalid product ID"
            self.showError = true
            completion(false, "Invalid product ID")
            return
        }

        let path = "\(Globs.SV_REMOVE_CART)?userId=\(userId)&productId=\(productId)"
        ServiceCall.delete(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    self.serviceCallList() // Làm mới danh sách giỏ hàng
                    completion(true, message)
                } else {
                    self.errorMessage = "Failed to remove item: Invalid response"
                    self.showError = true
                    completion(false, "Failed to remove item: Invalid response")
                }
            } else {
                self.errorMessage = "Failed to remove item: Invalid response format"
                self.showError = true
                completion(false, "Failed to remove item: Invalid response format")
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Failed to remove item"
            self.showError = true
            completion(false, self.errorMessage)
        }
    }
}
