import SwiftUI

class AdminViewModel: ObservableObject {
    
    @Published var productList: [ProductModel] = []
    @Published var bestSellingList: [ProductModel] = []
    @Published var exclusiveOfferList: [ProductModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var brands: [BrandModel] = []
    @Published var nutritions: [NutritionModel] = []
    @Published var customerAccounts: [UserModel] = [] // New property for customer accounts
    
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
        fetchNutritions()
        fetchCustomerAccounts() // Fetch accounts on initialization
    }

    private func resetAlerts() { // reset
        showError = false
        showSuccess = false
        errorMessage = ""
        successMessage = ""
    }

    // Existing methods...

    func fetchCustomerAccounts() {
        resetAlerts()
        let path = "\(Globs.BASE_URL)users" // Globs.BASE_URL = "https://api.example.com/users
        
        MainViewModel.shared.callApiWithTokenCheck(
            method: .get,
            path: path,
            parameters: [:],
            withSuccess: { responseObj in
                Task { @MainActor in // đảm bảo code chạy trên main thread, cần thiết để cập nhật @Published properties (như customerAccounts) an toàn
                    print("Raw API response: \(responseObj)") // Thêm log để kiểm tra dữ liệu gốc
                    if let response = responseObj as? NSArray {
                        let customers = response.compactMap { obj -> UserModel? in
                            guard let dict = obj as? NSDictionary,
                                  let roleDict = dict["role"] as? NSDictionary,
                                  let roleName = roleDict["roleName"] as? String,
                                  roleName.lowercased() == "customer" else {
                                return nil
                            }
                            let user = UserModel(dict: dict) // user = UserModel(id: 101, fullName: "John Doe", email: "john@example.com", role: "customer", createdAt: Date("2025-07-01T10:00:00Z"))
                            print("Parsed user: \(user.fullName), Role: \(user.role)") // Log người dùng được ánh xạ
                            return user
                        }
                        self.customerAccounts = customers // arrays of customers [UserModel]
                        print("Fetched customer accounts: \(self.customerAccounts.map { $0.fullName })")
                    } else {
                        self.errorMessage = "Failed to fetch customer accounts"
                        self.showError = true
                    }
                }
            },
            failure: { error in
                Task { @MainActor in
                    self.errorMessage = error?.localizedDescription ?? "Network error: Failed to fetch customer accounts"
                    self.showError = true
                }
            }
        )
    }
/*
 {
   "status": "success",
   "data": [
     {
       "id": 101,
       "fullName": "John Doe",
       "email": "john@example.com",
       "role": {
         "id": 2,
         "roleName": "customer"
       },
       "createdAt": "2025-07-01T10:00:00Z"
     },
     {
       "id": 102,
       "fullName": "Jane Smith",
       "email": "jane@example.com",
       "role": {
         "id": 2,
         "roleName": "customer"
       },
       "createdAt": "2025-07-02T12:00:00Z"
     },
     {
       "id": 103,
       "fullName": "Admin User",
       "email": "admin@example.com",
       "role": {
         "id": 1,
         "roleName": "admin"
       },
       "createdAt": "2025-07-03T08:00:00Z"
     }
   ],
   "message": "Users retrieved successfully"
 }
 */
    func deleteCustomerAccount(id: Int, completion: @escaping (Bool) -> Void) {
        resetAlerts()
        let path = "\(Globs.BASE_URL)users/delete/\(id)"
        
        MainViewModel.shared.callApiWithTokenCheck(
            method: .delete,
            path: path,
            parameters: [:],
            withSuccess: { responseObj in
                Task { @MainActor in
                    if let response = responseObj as? NSDictionary,
                       let message = response["message"] as? String,
                       message == "User deleted successfully" {
                        self.customerAccounts.removeAll { $0.id == id }
                        // Loại bỏ tất cả các UserModel trong mảng customerAccounts: [UserModel] có id khớp với tham số id được truyền vào hàm.
                        self.successMessage = "Account deleted successfully"
                        self.showSuccess = true
                        completion(true)
                    } else {
                        self.errorMessage = "Failed to delete account"
                        self.showError = true
                        completion(false)
                    }
                }
            },
            failure: { error in
                Task { @MainActor in
                    self.errorMessage = error?.localizedDescription ?? "Network error: Failed to delete account"
                    self.showError = true
                    completion(false)
                }
            }
        )
    }
    /*
     {
         "status": "success",
         "message": "User deleted successfully"
     }
     {
         "status": "error",
         "message": "User not found"
     }
     */

    // Existing methods (unchanged)...
    func addExclusiveOffer(discountPercentage: Double, startDate: Date, endDate: Date, productId: Int, completion: @escaping (Bool) -> Void) {
        resetAlerts()
        
        let offerParams: [String: Any] = [
            "discountPercentage": discountPercentage,
            "startDate": ISO8601DateFormatter().string(from: startDate),
            "endDate": ISO8601DateFormatter().string(from: endDate)
            /*
             discountPercentage = 20.0
             startDate = Date("2025-07-20T00:00:00Z") // 20/07/2025
             endDate = Date("2025-07-30T00:00:00Z")   // 30/07/2025
             */
        ]
        
        MainViewModel.shared.callApiWithTokenCheck(
            method: .post,
            path: Globs.SV_EXCLUSIVE_OFFER,
            parameters: offerParams as NSDictionary,
            withSuccess: { responseObj in
                if let response = responseObj as? NSDictionary,
                   let offerId = response["id"] as? Int {
                    let productParams: [String: Any] = [
                        "productId": productId
                    ]
                    
                    MainViewModel.shared.callApiWithTokenCheck(
                        method: .post,
                        path: "\(Globs.SV_EXCLUSIVE_OFFER)/\(offerId)/products", // POST https://api.example.com/exclusive-offers/123/products | Body: {"productId": 456}
                        parameters: productParams as NSDictionary,
                        withSuccess: { productResponse in
                            if productResponse != nil { // {"status": "success", "message": "Product added to offer successfully"}
                                DispatchQueue.main.async {
                                    self.fetchExclusiveOffers()
                                    self.successMessage = "Exclusive offer added successfully"
                                    self.showSuccess = true
                                    NotificationCenter.default.post(name: Self.productsUpdatedNotification, object: nil)
                                    // Gửi thông báo với tên productsUpdatedNotification để thông báo cho các thành phần khác (như view) rằng danh sách sản phẩm hoặc ưu đãi đã được cập nhật.
                                    completion(true)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.errorMessage = "Failed to add product to offer"
                                    self.showError = true
                                    completion(false)
                                }
                            }
                        },
                        failure: { error in
                            DispatchQueue.main.async {
                                self.errorMessage = error?.localizedDescription ?? "Network error: Failed to add product to offer"
                                self.showError = true
                                completion(false)
                            }
                        }
                    )
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to create offer"
                        self.showError = true
                        completion(false)
                    }
                }
            },
            failure: { error in
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Network error: Failed to create offer"
                    self.showError = true
                    completion(false)
                }
            }
        )
    }
/*
 {
     "status": "success",
     "id": 123,
     "message": "Exclusive offer created successfully"
 }
 */
    func fetchProducts() {
        resetAlerts()
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_HOME)?t=\(timestamp)&size=200"
        // pathWithTimestamp = "https://api.example.com/products?t=1753018680&size=200" | limit 200 prod
        
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
    /*
     {
         "status": "success",
         "content": [
             {
                 "id": 101,
                 "name": "T-Shirt",
                 "price": 19.99,
                 "category": "Clothing"
             },
             {
                 "id": 102,
                 "name": "Jeans",
                 "price": 49.99,
                 "category": "Clothing"
             }
         ],
         "message": "Products retrieved successfully"
     }
     
     */

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
    /*
     [
         {
             "id": 101,
             "name": "T-Shirt",
             "price": 19.99,
             "category": "Clothing"
         },
         {
             "id": 103,
             "name": "Sneakers",
             "price": 89.99,
             "category": "Footwear"
         }
     ]
     */

    
    /* [
     ProductModel(id: 101, name: "T-Shirt", unitName: "Piece", unitValue: 1.0, imageUrl: "https://example.com/tshirt.jpg", description: "Cotton T-Shirt", category: "Clothing", brand: "Nike", stock: 100, avgRating: 4.5, startDate: nil, endDate: nil, totalSold: 500, nutritionValues: [])
 ]
     */
    func fetchExclusiveOffers() {
        resetAlerts()
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_EXCLUSIVE_OFFER)/active?t=\(timestamp)"
        
        MainViewModel.shared.callApiWithTokenCheck(
            method: .get,
            path: pathWithTimestamp,
            parameters: [:],
            withSuccess: { responseObj in
                Task { @MainActor in
                    if let response = responseObj as? NSDictionary {
                        debugPrint("Admin Exclusive Offers Response: \(response)")
                        if let content = response.value(forKey: "content") as? NSArray {
                            var products: [ProductModel] = []
                            var uniqueProductIds: Set<Int> = []
                            
                            for offer in content {
                                if let offerDict = offer as? NSDictionary,
                                   let offerProducts = offerDict["products"] as? NSArray {
                                    for product in offerProducts {
                                        if let productDict = product as? NSDictionary,
                                           let productId = productDict["productId"] as? Int {
                                            if !uniqueProductIds.contains(productId) {
                                                uniqueProductIds.insert(productId)
                                                
                                                var mappedDict: [String: Any] = [:]
                                                mappedDict["id"] = productId
                                                mappedDict["name"] = productDict["productName"] as? String ?? ""
                                                mappedDict["price"] = productDict["originalPrice"] as? Double ?? 0.0
                                                mappedDict["offerPrice"] = productDict["offerPrice"] as? Double
                                                
                                                // matchingProduct = ProductModel(id: 101, unitName: "Piece", unitValue: 1.0, imageUrl: "https://example.com/tshirt.jpg", description: "Cotton T-Shirt", category: "Clothing", brand: "Nike", stock: 100, avgRating: 4.5, startDate: nil, endDate: nil, totalSold: 500).
                                                if let matchingProduct = self.productList.first(where: { $0.id == productId }) {
                                                    //Tìm sản phẩm trong self.productList có id khớp với productId trong productList
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
                                                    // mappedDict["nutritionValues"] = [["nutritionId": 201, "value": "25.0"]]
                                                }
                                                /*
                                                 mappedDict = [
                                                     "id": 101,
                                                     "name": "T-Shirt",
                                                     "price": 19.99,
                                                     "offerPrice": 15.99,
                                                     "unitName": "Piece",
                                                     "unitValue": 1.0,
                                                     "imageUrl": "https://example.com/tshirt.jpg",
                                                     "description": "Cotton T-Shirt",
                                                     "category": "Clothing",
                                                     "brand": "Nike",
                                                     "stock": 100,
                                                     "avgRating": 4.5,
                                                     "startDate": nil,
                                                     "endDate": nil,
                                                     "totalSold": 500
                                                 ]
                                                 */
                                                
                                                let productModel = ProductModel(dict: mappedDict as NSDictionary)
                                                products.append(productModel)
                                            } // if ! unique
                                        }
                                    } // for 2
                                }
                            } // for 1
                            self.exclusiveOfferList = products
                        } else {
                            self.errorMessage = "Failed to fetch exclusive offers"
                            self.showError = true
                        }
                    } else {
                        self.errorMessage = "Invalid response format"
                        self.showError = true
                    }
                }
            },
            failure: { error in
                Task { @MainActor in
                    self.errorMessage = error?.localizedDescription ?? "Network error: Failed to fetch exclusive offers"
                    self.showError = true
                }
            }
        )
    }
    /*
     {
         "status": "success",
         "content": [
             {
                 "id": 123,
                 "discountPercentage": 20.0,
                 "startDate": "2025-07-20T00:00:00Z",
                 "endDate": "2025-07-30T00:00:00Z",
                 "products": [
                     {
                         "productId": 101,
                         "productName": "T-Shirt",
                         "originalPrice": 19.99,
                         "offerPrice": 15.99
                     },
                     {
                         "productId": 102,
                         "productName": "Jeans",
                         "originalPrice": 49.99,
                         "offerPrice": 39.99
                     }
                 ]
             },
             {
                 "id": 124,
                 "discountPercentage": 15.0,
                 "startDate": "2025-07-21T00:00:00Z",
                 "endDate": "2025-07-28T00:00:00Z",
                 "products": [
                     {
                         "productId": 103,
                         "productName": "Sneakers",
                         "originalPrice": 89.99,
                         "offerPrice": 76.49
                     }
                 ]
             }
         ],
         "message": "Exclusive offers retrieved successfully"
     }
     */
    
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
/*
 [
     {
         "id": 1,
         "name": "Clothing",
         "description": "Apparel and fashion items"
     },
     {
         "id": 2,
         "name": "Footwear",
         "description": "Shoes and sneakers"
     },
     {
         "id": 3,
         "name": "Accessories",
         "description": "Bags, hats, and more"
     }
 ]
 */
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
    /*
     [
         {
             "id": 1,
             "name": "Nike",
             "description": "Sportswear brand"
         },
         {
             "id": 2,
             "name": "Adidas",
             "description": "Athletic apparel"
         }
     ]
     */

    func fetchNutritions() {
        resetAlerts()
        ServiceCall.get(path: Globs.SV_NUTRITIONS) { responseObj in
            if let response = responseObj as? NSDictionary,
               let content = response["content"] as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.nutritions = content.map { NutritionModel(dict: $0) }
                    print("Fetched nutritions: \(self.nutritions.map { $0.name })")
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch nutritions: Invalid response format"
                    self.showError = true
                    print("Failed to parse nutritions: \(String(describing: responseObj))")
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                print("Network error: \(String(describing: error))")
            }
        }
    }
/*
 {
     "status": "success",
     "content": [
         {
             "id": 201,
             "name": "Protein Shake",
             "calories": 200,
             "protein": 25.0
         },
         {
             "id": 202,
             "name": "Energy Bar",
             "calories": 150,
             "protein": 10.0
         }
     ],
     "message": "Nutritions retrieved successfully"
 }
 */
    func addProduct(product: ProductRequestModel, completion: @escaping (Bool) -> Void) {
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
    /*
     {
         "status": "success",
         "id": 103,
         "message": "Product added successfully"
     }
     parameters:
     [
         "name": "New T-Shirt",
         "price": 29.99,
         "unitName": "Piece",
         "unitValue": 1.0,
         "imageUrl": "https://example.com/new_tshirt.jpg",
         "description": "Premium Cotton T-Shirt",
         "category": "Clothing",
         "brand": "Nike",
         "stock": 200,
         "avgRating": 0.0,
         "totalSold": 0,
         "nutritionValues": []
     ]
     */

    func updateProduct(id: Int, product: ProductRequestModel, completion: @escaping (Bool) -> Void) {
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
/*
 let updatedProduct = ProductRequestModel(name: "Updated T-Shirt", price: 34.99, ...)
 updateProduct(id: 101, product: updatedProduct) { success in
     print("Update product: \(success ? "Success" : "Failed")")
 }
 Response
 {
     "status": "success",
     "id": 101,
     "name": "Updated T-Shirt",
     "message": "Product updated successfully"
 }
 */
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
    /*
     if let response = responseObj as? NSDictionary,
                let status = response["status"] as? String,
                status == "success" {
     */

    func searchProducts(name: String?, brandId: Int?, categoryId: Int?) {
        resetAlerts()
        
        var queryItems: [String] = []
        if let name = name { // name=T-Shirt%20Pro
            queryItems.append("name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let brandId = brandId {
            queryItems.append("brandId=\(brandId)")
        }
        if let categoryId = categoryId {
            queryItems.append("categoryId=\(categoryId)")
        }
        let queryString = queryItems.joined(separator: "&") // name=T-Shirt%20Pro&brandId=1
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

struct ProductRequestModel: Identifiable {
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
    var avgRating: Double?
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
        
        if let description = description {
            dict["description"] = description
        }
        if let imageUrl = imageUrl { dict["imageUrl"] = imageUrl }
        if let categoryId = categoryId { dict["categoryId"] = categoryId }
        if let brandId = brandId { dict["brandId"] = brandId }
        if let offerPrice = offerPrice, !offerPrice.isNaN { dict["offerPrice"] = offerPrice }
        if let avgRating = avgRating, !avgRating.isNaN { dict["avgRating"] = avgRating }
        
        if let startDate = startDate {
            dict["startDate"] = ISO8601DateFormatter().string(from: startDate)
        }
        if let endDate = endDate {
            dict["endDate"] = ISO8601DateFormatter().string(from: endDate)
        }
        
        if let nutritionValues = nutritionValues {
            dict["nutritionValues"] = nutritionValues.map { nutrition in
                [
                    "nutritionId": nutrition.nutritionId,
                    "value": String(nutrition.value)
                ]
            }
        } else {
            dict["nutritionValues"] = []
        }
        
        return dict
    }// func
}
/*
 dict:
 [
     "name": "New T-Shirt",
     "price": 29.99,
     "stock": 200,
     "unitName": "Piece",
     "unitValue": "1.0",
     "description": "Premium Cotton T-Shirt",
     "imageUrl": "https://example.com/new_tshirt.jpg",
     "categoryId": 1,
     "brandId": 1,
     "offerPrice": 24.99,
     "avgRating": 0.0,
     "startDate": "2025-07-20T17:31:00Z",
     "nutritionValues": [
         ["nutritionId": 1, "value": "100.0"]
     ]
 ]
 */
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
