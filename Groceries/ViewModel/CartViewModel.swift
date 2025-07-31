//
//  CartViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.

// CartViewModel.swift

import SwiftUI

class CartViewModel: ObservableObject {
    static var shared: CartViewModel = CartViewModel()

    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var listArr: [CartItemModel] = []
    @Published var total: String = "0.0"

    private var userId: Int {
        guard let userId = Utils.UDValue(key: "userId") as? Int else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in. Please log in again."
                self.showError = true
                self.listArr = []
                self.total = "0.0"
            }
            return 0
        }
        return userId
    }

    init() {
        if userId != 0 {
            serviceCallList()
        }
    }

    func serviceCallList() {
        guard userId != 0 else { return }
        let path = "\(Globs.SV_CART_LIST)?userId=\(userId)"
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                print("Cart API Response: \(response)")
                if let items = response["items"] as? NSArray { // items
                    let newItems = items.map { CartItemModel(dict: $0 as? NSDictionary ?? [:]) } // newItems
                    DispatchQueue.main.async {
                        self.listArr = newItems
                        // listArr được gán [CartItemModel(id: 123, ...), CartItemModel(id: 124, ...), CartItemModel(id: 125, ...)]. MyCartView tự động render 3 CartItemRow cho Táo, Chuối, Cam.
                        let calculatedTotal = newItems.reduce(0.0) { $0 + $1.totalPrice }
                        /*
                         - reduce: Gộp các phần tử trong newItems thành một giá trị duy nhất (tổng totalPrice).
                         - 0.0: Giá trị khởi tạo (tổng bắt đầu bằng 0).
                         Bắt đầu: $0 = 0.0.
                         Phần tử 1: $0 = 0.0 + 80.0 = 80.0.
                         Phần tử 2: $0 = 80.0 + 50.0 = 130.0.
                         Phần tử 3: $0 = 130.0 + 60.0 = 190.0.
                         Kết quả: calculatedTotal = 190.0.
                         */
                        self.total = String(format: "%.2f", calculatedTotal)
                        print("Calculated Total: \(self.total)")
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
    /*
     {
         "items": [
             {
                 "id": 123,
                 "productName": "Táo Gala",
                 "totalPrice": 80.0,
                 "quantity": 2,
                 "price": 40.0
             },
             {
                 "id": 124,
                 "productName": "Chuối",
                 "totalPrice": 50.0,
                 "quantity": 5,
                 "price": 10.0
             },
             {
                 "id": 125,
                 "productName": "Cam",
                 "totalPrice": 60.0,
                 "quantity": 3,
                 "price": 20.0
             }
         ]
     }
     newItems = [
         CartItemModel(id: 123, productName: "Táo Gala", totalPrice: 80.0),
         CartItemModel(id: 124, productName: "Chuối", totalPrice: 50.0),
         CartItemModel(id: 125, productName: "Cam", totalPrice: 60.0)
     ]
     */

    func serviceCallAddToCart(prodId: Int, qty: Int, completion: @escaping (Bool, String) -> Void) {
        guard userId != 0 else {
            self.errorMessage = "User not logged in. Please log in again."
            self.showError = true
            completion(false, self.errorMessage)
            return
        }

        let path = "\(Globs.SV_ADD_CART)?productId=\(prodId)&quantity=\(qty)&userId=\(userId)"
        ServiceCall.post(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    print("Success: \(message)")
                    // {"message": "Added to cart"}
                    // {"error": "Product not found"}
                    DispatchQueue.main.async {
                        self.serviceCallList()
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Failed to add to cart: Invalid response"
                        self.showError = true
                    }
                    completion(false, self.errorMessage)
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

    func addMultipleToCart(products: [ProductModel], completion: @escaping (Bool, String) -> Void) {
        guard userId != 0 else {
            self.errorMessage = "User not logged in. Please log in again."
            self.showError = true
            completion(false, self.errorMessage)
            return
        }

        guard !products.isEmpty else {
            completion(false, "No products to add to cart.")
            return
        }

        var successCount = 0
        var errorMessages: [String] = []
        let totalCount = products.count

        let dispatchGroup = DispatchGroup()
        /*
         Khởi tạo một instance DispatchGroup để quản lý các tác vụ bất đồng bộ.
         Lúc này, bộ đếm tác vụ của DispatchGroup là 0.
         
         Gọi enter() để báo DispatchGroup rằng một tác vụ mới bắt đầu.
         Tăng bộ đếm tác vụ lên 1 (ví dụ: từ 0 thành 1, rồi 2, v.v.).
         Mỗi sản phẩm trong vòng lặp sẽ gọi enter() một lần.
         */
        for product in products {
            dispatchGroup.enter()
            serviceCallAddToCart(prodId: product.id, qty: 1) { success, message in
                if success {
                    successCount += 1
                } else {
                    errorMessages.append("Failed to add \(product.name): \(message)")
                }
                dispatchGroup.leave() // Gọi leave() để báo rằng tác vụ (API call) đã hoàn tất.
            }
        }
        /*
         3 sản phẩm → 3 lần enter() → bộ đếm = 3.
         Mỗi serviceCallAddToCart hoàn tất → leave() → bộ đếm giảm (3 → 2 → 1 → 0).
         Khi bộ đếm = 0, notify() chạy.
         */
        dispatchGroup.notify(queue: .main) { // Khi tất cả serviceCallAddToCart hoàn tất (bộ đếm về 0), notify chạy để báo cáo kết quả.
            if successCount == totalCount {
                completion(true, "All items added to cart successfully.")
            } else if successCount > 0 {
                completion(true, "Added \(successCount)/\(totalCount) items. Errors: \(errorMessages.joined(separator: "; "))")
            } else {
                completion(false, "Failed to add items to cart: \(errorMessages.joined(separator: "; "))")
            }
        }
    }
    func serviceCallUpdateQty(cObj: CartItemModel, newQty: Int, completion: @escaping (Bool, String) -> Void) {
        guard userId != 0 else {
            self.errorMessage = "User not logged in. Please log in again."
            self.showError = true
            completion(false, self.errorMessage)
            return
        }

        guard let productId = cObj.productId else {
            self.errorMessage = "Invalid product ID"
            self.showError = true
            completion(false, "Invalid product ID")
            return
        }

        let path = "\(Globs.SV_UPDATE_CART)?productId=\(productId)&quantity=\(newQty)&userId=\(userId)"

        ServiceCall.put(parameter: [:], path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    DispatchQueue.main.async {
                        if let index = self.listArr.firstIndex(where: { $0.id == cObj.id }) {// tìm vị trí của sp được cập nhậtcó id trùng với cObj.id trong listArr
                            self.listArr[index].quantity = newQty // cập nhật số lượng
                            self.listArr[index].totalPrice = Double(newQty) * self.listArr[index].price // Use price directly
                            self.listArr = self.listArr
                            let calculatedTotal = self.listArr.reduce(0.0) { $0 + $1.totalPrice } // Tính tổng giá trị giỏ hàng
                            self.total = String(format: "%.2f", calculatedTotal)
                            print("Updated Total after qty change: \(self.total)")
                        }
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Failed to update quantity: Invalid response"
                        self.showError = true
                        completion(false, self.errorMessage)
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

    func serviceCallRemove(cObj: CartItemModel, completion: @escaping (Bool, String) -> Void) {
        guard userId != 0 else {
            self.errorMessage = "User not logged in. Please log in again."
            self.showError = true
            completion(false, self.errorMessage)
            return
        }

        guard let productId = cObj.productId else {
            self.errorMessage = "Invalid product ID"
            self.showError = true
            completion(false, "Invalid product ID")
            return
        }

        let path = "\(Globs.SV_REMOVE_CART)?productId=\(productId)&userId=\(userId)"
        ServiceCall.delete(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let message = response["message"] as? String {
                    DispatchQueue.main.async {
                        self.serviceCallList()
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Failed to remove item: Invalid response"
                        self.showError = true
                        completion(false, self.errorMessage)
                    }
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to remove item"
                self.showError = true
                completion(false, self.errorMessage)
            }
        }
    }
}
