//
//  HomeViewModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 7/12/24.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    static var shared: HomeViewModel = HomeViewModel()
    
    @Published var selectTab: Int = 0
    @Published var txtSearch: String = ""
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var productList: [ProductModel] = []
    @Published var bestSellingList: [ProductModel] = []
    @Published var exclusiveOfferList: [ProductModel] = []

    init() {
        serviceCallList()
        serviceCallBestSelling()
        serviceCallExclusiveOffers()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(productsUpdated),
            name: AdminViewModel.productsUpdatedNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func productsUpdated() {
        serviceCallList()
        serviceCallBestSelling()
        serviceCallExclusiveOffers()
    }

    func serviceCallList() {
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_HOME)?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary {
                debugPrint("HomeViewModel Response: \(response)")
                if let content = response.value(forKey: "content") as? NSArray {
                    DispatchQueue.main.async {
                        self.productList = content.map { obj in
                            return ProductModel(dict: obj as? NSDictionary ?? [:])
                        }
                    }
                } else {
                    let error = response.value(forKey: "error") as? String ?? "Unknown error"
                    let errorCode = response.value(forKey: "errorCode") as? String ?? "Unknown error code"
                    self.errorMessage = "Failed to load products: \(error) (\(errorCode))"
                    self.showError = true
                }
            } else {
                self.errorMessage = "Invalid response format"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error: Failed to load products"
            self.showError = true
        }
    }

    func serviceCallBestSelling() {
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_BEST_SELLING)?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSArray {
                DispatchQueue.main.async {
                    self.bestSellingList = response.map { obj in
                        return ProductModel(dict: obj as? NSDictionary ?? [:])
                    }
                }
            } else {
                self.errorMessage = "Failed to load best-selling products"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error: Failed to load best-selling products"
            self.showError = true
        }
    }

    func serviceCallExclusiveOffers() {
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_EXCLUSIVE_OFFER)/active?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary {
                debugPrint("Exclusive Offers Response: \(response)")
                if let content = response.value(forKey: "content") as? NSArray {
                    var products: [ProductModel] = []
                    for offer in content {
                        if let offerDict = offer as? NSDictionary,
                           let offerProducts = offerDict["products"] as? NSArray {
                            for product in offerProducts {
                                if let productDict = product as? NSDictionary {
                                    // Ánh xạ các trường từ OfferProductResponseDTO sang định dạng ProductModel mong đợi
                                    var mappedDict: [String: Any] = [:]
                                    mappedDict["id"] = productDict["productId"] as? Int ?? 0
                                    mappedDict["name"] = productDict["productName"] as? String ?? ""
                                    mappedDict["price"] = productDict["originalPrice"] as? Double ?? 0.0
                                    mappedDict["offerPrice"] = productDict["offerPrice"] as? Double

                                    // Tìm sản phẩm trong productList để lấy các trường thiếu
                                    if let productId = mappedDict["id"] as? Int,
                                       let matchingProduct = self.productList.first(where: { $0.id == productId }) {
                                        mappedDict["unitName"] = matchingProduct.unitName
                                        mappedDict["unitValue"] = matchingProduct.unitValue
                                        mappedDict["imageUrl"] = matchingProduct.imageUrl
                                        mappedDict["description"] = matchingProduct.description
                                        mappedDict["category"] = matchingProduct.category
                                        mappedDict["brand"] = matchingProduct.brand
                                        mappedDict["stock"] = matchingProduct.stock
                                        mappedDict["avgRating"] = matchingProduct.avgRating
                                        mappedDict["startDate"] = matchingProduct.startDate?.iso8601String()
                                        mappedDict["endDate"] = matchingProduct.endDate?.iso8601String()
                                        mappedDict["totalSold"] = matchingProduct.totalSold
                                        mappedDict["nutritionValues"] = matchingProduct.nutritionValues.map { ["nutritionId": $0.nutritionId, "value": String($0.value)] }
                                    }

                                    let productModel = ProductModel(dict: mappedDict as NSDictionary)
                                    products.append(productModel)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.exclusiveOfferList = products
                    }
                } else {
                    self.errorMessage = "Failed to load exclusive offers"
                    self.showError = true
                }
            } else {
                self.errorMessage = "Invalid response format"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error: Failed to load exclusive offers"
            self.showError = true
        }
    }
}
