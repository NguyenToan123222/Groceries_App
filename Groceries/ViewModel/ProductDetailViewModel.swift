//
//  ProductDetailViewModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.

import Foundation

class ProductDetailViewModel: ObservableObject {
    @Published var pObj: ProductModel
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var qty: Int = 1

    init(productId: Int) {
        self.pObj = ProductModel(dict: [:])
        serviceCallDetail(productId: productId)
    }

    func serviceCallDetail(productId: Int) {
        let path = Globs.SV_PRODUCT_DETAIL.replacingOccurrences(of: "{id}", with: "\(productId)")
        ServiceCall.get(path: path) { responseObj in
            if let response = responseObj as? NSDictionary {
                var mappedDict: [String: Any] = response as? [String: Any] ?? [:]
                // Ánh xạ offerPrice và discountPercentage từ offer
                if let offerDict = response["offer"] as? NSDictionary {
                    // response = ["id": 123, "name": "Rau muống", "offer": ["offerPrice": 15000, "discountPercentage": 25]].
                    // offerDict = ["offerPrice": 15000, "discountPercentage": 25, "startDate": "2025-06-20", "endDate": "2025-06-30"].
                    if let offerPrice = offerDict["offerPrice"] as? Double {
                        mappedDict["offerPrice"] = offerPrice
                    }
                    if let discountPercentage = offerDict["discountPercentage"] as? Double {
                        mappedDict["discountPercentage"] = discountPercentage
                    }
                    if let startDate = offerDict["startDate"] as? String {
                        mappedDict["startDate"] = startDate
                    }
                    if let endDate = offerDict["endDate"] as? String {
                        mappedDict["endDate"] = endDate
                    }
                } // mappedDict: ["id": 123, "name": "Rau muống", "offerPrice": 15000, "discountPercentage": 25, "startDate": "2025-06-20", "endDate": "2025-06-30"]
                DispatchQueue.main.async {
                    self.pObj = ProductModel(dict: mappedDict as NSDictionary)
                }
            } else {
                self.errorMessage = "Không thể phân tích chi tiết sản phẩm"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Lỗi mạng"
            self.showError = true
        }
    }

    func addSubQty(isAdd: Bool = true) {
        if isAdd {
            qty = min(qty + 1, 99) // Tăng qty lên 1, nhưng không quá 99 (min).
        } else {
            qty = max(qty - 1, 1) // Giảm qty xuống 1, nhưng không dưới 1 (max).
        }
    }
}
