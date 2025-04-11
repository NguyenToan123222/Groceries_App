//
//  AdminViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 26/3/25.

import SwiftUI

class AdminViewModel: ObservableObject {
    @Published var productList: [ProductModel] = []
    @Published var bestSellingList: [ProductModel] = []
    @Published var exclusiveOfferList: [ProductModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var brands: [BrandModel] = []
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""

    static let productsUpdatedNotification = Notification.Name("ProductsUpdatedNotification")

    init() {
        fetchCategories()
        fetchBrands()
        fetchProducts()
        fetchBestSelling()
        fetchExclusiveOffers()
    }

    private func resetAlerts() {
        showError = false
        showSuccess = false
        errorMessage = ""
        successMessage = ""
    }

    func fetchProducts() {
        resetAlerts()
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_HOME)?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary,
               let content = response["content"] as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.productList = content.map { ProductModel(dict: $0) }
                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                }
            } else {
                self.errorMessage = "Failed to fetch products from server"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    func fetchBestSelling() {
        resetAlerts()
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
                self.errorMessage = "Failed to fetch best-selling products"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    func fetchExclusiveOffers() {
        resetAlerts()
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_EXCLUSIVE_OFFER)/active?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary {
                debugPrint("Admin Exclusive Offers Response: \(response)")
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
                    self.errorMessage = "Failed to fetch exclusive offers"
                    self.showError = true
                }
            } else {
                self.errorMessage = "Invalid response format"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error: Failed to fetch exclusive offers"
            self.showError = true
        }
    }

    func fetchCategories() {
        resetAlerts()
        ServiceCall.get(path: Globs.SV_CATEGORIES) { responseObj in
            if let response = responseObj as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.categories = response.map { CategoryModel(dict: $0) }
                }
            } else {
                self.errorMessage = "Failed to fetch categories"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    func fetchBrands() {
        resetAlerts()
        ServiceCall.get(path: Globs.SV_BRANDS) { responseObj in
            if let response = responseObj as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.brands = response.map { BrandModel(dict: $0) }
                }
            } else {
                self.errorMessage = "Failed to fetch brands"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    func addProduct(product: ProductRequestModel, completion: @escaping (Bool) -> Void) {
        if product.name.isEmpty || product.price <= 0 || product.stock <= 0 || product.unitName.isEmpty || product.unitValue.isEmpty || product.categoryId == nil || product.brandId == nil {
            self.errorMessage = "Please fill in all required fields, including Category and Brand"
            self.showError = true
            completion(false)
            return
        }

        resetAlerts()
        let parameters = product.toDict()
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_ADD_PRODUCT) { responseObj in
            if let response = responseObj as? NSDictionary,
               let id = response["id"] as? Int, id > 0 {
                DispatchQueue.main.async {
                    self.fetchProducts()
                    self.fetchBestSelling()
                    self.fetchExclusiveOffers()
                    self.successMessage = "Product added successfully"
                    self.showSuccess = true
                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                    completion(true)
                }
            } else {
                self.errorMessage = "Failed to add product"
                self.showError = true
                completion(false)
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
            completion(false)
        }
    }

    func updateProduct(id: Int, product: ProductRequestModel, completion: @escaping (Bool) -> Void) {
        if product.name.isEmpty || product.price <= 0 || product.stock <= 0 || product.unitName.isEmpty || product.unitValue.isEmpty || product.categoryId == nil || product.brandId == nil {
            self.errorMessage = "Please fill in all required fields, including Category and Brand"
            self.showError = true
            completion(false)
            return
        }

        resetAlerts()
        let path = Globs.SV_UPDATE_PRODUCT.replacingOccurrences(of: "{id}", with: String(id))
        let parameters = product.toDict()
        debugPrint("Update Product Request: \(parameters)")
        ServiceCall.put(parameter: parameters as NSDictionary, path: path) { responseObj in
            debugPrint("Update Product Response: \(String(describing: responseObj))")
            if let response = responseObj as? NSDictionary,
               let responseId = response["id"] as? Int,
               responseId == id,
               let updatedName = response["name"] as? String,
               updatedName == product.name {
                DispatchQueue.main.async {
                    self.fetchProducts()
                    self.fetchBestSelling()
                    self.fetchExclusiveOffers()
                    self.successMessage = "Product updated successfully"
                    self.showSuccess = true
                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                    completion(true)
                }
            } else {
                self.errorMessage = (responseObj as? NSDictionary)?["message"] as? String ?? "Failed to update product"
                self.showError = true
                completion(false)
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
            completion(false)
        }
    }

    func deleteProduct(id: Int, completion: @escaping (Bool) -> Void) {
        resetAlerts()
        let path = Globs.SV_DELETE_PRODUCT.replacingOccurrences(of: "{id}", with: String(id))
        ServiceCall.delete(path: path) { responseObj in
            if responseObj != nil {
                DispatchQueue.main.async {
                    self.fetchProducts()
                    self.fetchBestSelling()
                    self.fetchExclusiveOffers()
                    self.successMessage = "Product deleted successfully"
                    self.showSuccess = true
                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                    completion(true)
                }
            } else {
                self.errorMessage = "Failed to delete product"
                self.showError = true
                completion(false)
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
            completion(false)
        }
    }

    func searchProducts(name: String?, brandId: Int?, categoryId: Int?) {
        resetAlerts()
        
        var queryItems: [String] = []
        if let name = name {
            queryItems.append("name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let brandId = brandId {
            queryItems.append("brandId=\(brandId)")
        }
        if let categoryId = categoryId {
            queryItems.append("categoryId=\(categoryId)")
        }
        let queryString = queryItems.joined(separator: "&")
        let path = queryString.isEmpty ? "\(Globs.SV_FILTER_PRODUCTS)" : "\(Globs.SV_FILTER_PRODUCTS)?\(queryString)"
        
        print("Search URL: \(path)")
        
        ServiceCall.get(path: path) { responseObj in
            print("Search Response: \(String(describing: responseObj))")
            if let response = responseObj as? NSDictionary,
               let content = response["content"] as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.productList = content.map { ProductModel(dict: $0) }
                    print("Search Results: \(self.productList.map { $0.name })")
                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                }
            } else {
                self.errorMessage = "Failed to search products"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }
}
struct ProductRequestModel {
    var id: Int?
    var name: String
    var price: Double
    var stock: Int
    var unitName: String
    var unitValue: String
    var description: String?
    var imageUrl: String?
    var categoryId: Int?
    var brandId: Int?
    var offerPrice: Double?
    var avgRating: Int?
    var startDate: Date?
    var endDate: Date?
    var nutritionValues: [NutritionValueModel]?

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "price": price,
            "stock": stock,
            "unitName": unitName,
            "unitValue": unitValue
        ]
        // Don't include ID in the request body - the backend may use the path parameter
        // if let id = id { dict["id"] = id }
        
        if let description = description { dict["description"] = description }
        if let imageUrl = imageUrl { dict["imageUrl"] = imageUrl }
        if let categoryId = categoryId { dict["categoryId"] = categoryId }
        if let brandId = brandId { dict["brandId"] = brandId }
        if let offerPrice = offerPrice { dict["offerPrice"] = offerPrice }
        if let avgRating = avgRating { dict["avgRating"] = avgRating }
        
        // Format dates properly
        if let startDate = startDate {
            dict["startDate"] = ISO8601DateFormatter().string(from: startDate)
        }
        if let endDate = endDate {
            dict["endDate"] = ISO8601DateFormatter().string(from: endDate)
        }
        
        // Always include nutritionValues as an array, empty if needed
        if let nutritionValues = nutritionValues {
            dict["nutritionValues"] = nutritionValues.map { ["nutritionId": $0.nutritionId, "value": $0.value] }
        } else {
            dict["nutritionValues"] = []
        }
        
        return dict
    }
}

extension String {
    func iso8601Date() -> Date? {
        ISO8601DateFormatter().date(from: self)
    }
}

extension Date {
    func iso8601String() -> String {
        ISO8601DateFormatter().string(from: self)
    }
}
