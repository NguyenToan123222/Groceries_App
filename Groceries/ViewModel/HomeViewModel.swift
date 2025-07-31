//
//  HomeViewModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 7/12/24.
//
import Foundation

class HomeViewModel: ObservableObject {
    static var shared: HomeViewModel = HomeViewModel()
    
    @Published var selectTab: Int = 0
    @Published var txtSearch: String = ""
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""
    
    @Published var share: Bool = false

    @Published var productList: [ProductModel] = []
    @Published var bestSellingList: [ProductModel] = []
    @Published var exclusiveOfferList: [ProductModel] = []
    @Published var filteredProducts: [ProductModel] = []
    
    @Published var categories: [CategoryModel] = []
    @Published var categorizedProducts: [(category: CategoryModel, products: [ProductModel])] = []
    @Published var uncategorizedProducts: [ProductModel] = []
    

    init() {
        fetchCategories()
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

    func searchProducts(name: String?) {
        if let name = name, !name.isEmpty { // name = nil hoặc name = ""
            var queryItems: [String] = []
            queryItems.append("name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
            /*
             name = "rau muống", sau khi mã hóa: queryItems = ["name=rau%20muong"].
             name = "cà chua", sau khi mã hóa: queryItems = ["name=c%C3%A0%20chua"].
             */
            let queryString = queryItems.joined(separator: "&")
            /*
             queryItems = ["name=rau%20muong"] → queryString = "name=rau%20muong".
             Nếu có nhiều tham số (như ["name=rau%20muong", "category=vegetable"]): queryString = "name=rau%20muong&category=vegetable".
             */
            let path = "\(Globs.SV_FILTER_PRODUCTS)?\(queryString)"
            
            ServiceCall.get(path: path) { responseObj in
                if let response = responseObj as? NSDictionary,
                   let content = response["content"] as? [NSDictionary] {
                    /*
                     {
                       "content": [
                         {"id": 123, "name": "Rau muống", "price": 20000},
                         {"id": 124, "name": "Rau muống baby", "price": 25000}
                       ]
                     }
                     */
                    DispatchQueue.main.async {
                        self.filteredProducts = content.map { ProductModel(dict: $0) }
                        /*
                         content = [ {"id": 123, "name": "Rau muống", "price": 20000}, {"id": 124, "name": "Rau muống baby", "price": 25000} ].
                         filteredProducts = [ProductModel(id: 123, name: "Rau muống", price: 20000), ProductModel(id: 124, name: "Rau muống baby", price: 25000)].
                         */
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to search products"
                        self.showError = true
                    }
                }
            } failure: { error in
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Network error"
                    self.showError = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.filteredProducts = [] // Nếu name là nil hoặc rỗng, giao diện không hiển thị kết quả tìm kiếm.
            }
        }
    }

    func serviceCallList() {
        let timestamp = String(Date().timeIntervalSince1970)
        /*
         Tạo timestamp để thêm vào URL API, tránh cache (đảm bảo server trả dữ liệu mới nhất).
         Date().timeIntervalSince1970 = 1753184040.0.
         timestamp = "1753184040"
         */
        let pathWithTimestamp = "\(Globs.SV_HOME)?t=\(timestamp)&size=200"
        // https://api.groceries.com/home?t=1753184040&size=200
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary {
                /*
                 {
                   "content": [
                     {"id": 123, "name": "Rau muống", "price": 20000, "offer": {"offerPrice": 15000, "discountPercentage": 25}},
                     {"id": 124, "name": "Cải ngọt", "price": 15000}
                   ]
                 }
                 */
                if let content = response.value(forKey: "content") as? NSArray {
                    DispatchQueue.main.async {
                        self.productList = content.map { dict in // [ProductModel(id: 123, ...), ProductModel(id: 124, ...)].
                            let productDict = dict as? NSDictionary ?? [:]
                            var mappedDict: [String: Any] = productDict as? [String: Any] ?? [:]
                            // Ánh xạ offerPrice và discountPercentage từ offer/*
                            /*
                             productDict = {"id": 123, "name": "Rau muống", "price": 20000, "offer": {...}}.
                             mappedDict = ["id": 123, "name": "Rau muống", "price": 20000, "offer": {...}].
                             */
                            if let offerDict = productDict["offer"] as? NSDictionary {
                                /*
                                 productDict = {"id": 123, ..., "offer": {"offerPrice": 15000, "discountPercentage": 25}}.
                                 offerDict = {"offerPrice": 15000, "discountPercentage": 25, ...}.
                                 */
                                if let offerPrice = offerDict["offerPrice"] as? Double {
                                    mappedDict["offerPrice"] = offerPrice
                                    /*
                                     offerDict["offerPrice"] = 15000
                                     mappedDict["offerPrice"] = 15000
                                     */
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
                            }
                            return ProductModel(dict: mappedDict as NSDictionary)
                            /*
                             mappedDict = ["id": 123, "name": "Rau muống", "price": 20000, "offerPrice": 15000, "discountPercentage": 25, ...].
                             ProductModel(dict: mappedDict as NSDictionary) tạo đối tượng với các thuộc tính như id, name, offerPrice.
                             */
                        }
                        self.updateCategorizedProducts()
                        /*
                         Phân loại lại sản phẩm theo danh mục.
                         Cập nhật giao diện Home với các section danh mục mới
                        */
                        self.searchProducts(name: self.txtSearch) // cập nhật trạng thái tìm kiếm của filteredProducts []'[p['
                        self.serviceCallExclusiveOffers()
                    }// DispatchQueue
                } else {
                    self.errorMessage = "Không tải được sản phẩm"
                    self.showError = true
                }
            } else {
                self.errorMessage = "Định dạng phản hồi không hợp lệ"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Lỗi mạng"
            self.showError = true
        }
    }
    private func updateCategorizedProducts() {
        var categorized: [(category: CategoryModel, products: [ProductModel])] = []
        for category in categories {
            let productsInCategory = productList.filter { product in
                product.category?.lowercased() == category.name.lowercased() // return all object [ProductModel] id, name, price, category, v.v.)
            }
            if !productsInCategory.isEmpty {
                categorized.append((category: category, products: productsInCategory))
            }
        }// for
        self.categorizedProducts = categorized
        
        self.uncategorizedProducts = productList.filter { product in
            let categoryName = product.category?.lowercased()
            return categoryName == nil || categoryName?.isEmpty == true || !categories.contains { $0.name.lowercased() == categoryName }
        }
    }

    func serviceCallBestSelling() {
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_BEST_SELLING)?t=\(timestamp)"
        // pathWithTimestamp = "https://api.groceries.com/best-selling?t=1750924740.0".
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSArray {
                DispatchQueue.main.async {
                    self.bestSellingList = response.map { dict in
                        let productDict = dict as? NSDictionary ?? [:]
                        var mappedDict: [String: Any] = productDict as? [String: Any] ?? [:]
                        // Ánh xạ offerPrice và discountPercentage
                        if let offerPrice = productDict["offerPrice"] as? Double {
                            mappedDict["offerPrice"] = offerPrice
                        }
                        if let discountPercentage = productDict["discountPercentage"] as? Double {
                            mappedDict["discountPercentage"] = discountPercentage
                        }
                        return ProductModel(dict: mappedDict as NSDictionary)
                    } // self
                }
            } else {
                self.errorMessage = "Failed to load best sellings"
                self.showError = true
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    /* Offer
     {
       "content": [
         {
           "startDate": "2025-06-20",
           "endDate": "2025-06-30",
           "discountPercentage": 25.0,
           "products": [
             {"productId": 123, "productName": "Rau muống", "originalPrice": 20000, "offerPrice": 15000, "discountPercentage": 25.0},
             {"productId": 125, "productName": "Táo Fuji", "originalPrice": 30000, "offerPrice": 24000, "discountPercentage": 20.0}
           ]
         },
         {
           "startDate": "2025-06-22",
           "endDate": "2025-07-01",
           "discountPercentage": 30.0,
           "products": [
             {"productId": 123, "productName": "Rau muống", "originalPrice": 20000, "offerPrice": 14000, "discountPercentage": 30.0},
             {"productId": 127, "productName": "Cá hồi", "originalPrice": 200000, "offerPrice": 170000, "discountPercentage": 15.0}
           ]
         },
         {
           "startDate": "2025-06-25",
           "endDate": "2025-07-05",
           "discountPercentage": 10.0,
           "products": [
             {"productId": 125, "productName": "Táo Fuji", "originalPrice": 30000, "offerPrice": 27000, "discountPercentage": 10.0},
             {"productId": 129, "productName": "Sữa tươi", "originalPrice": 25000, "offerPrice": 22500, "discountPercentage": 10.0}
           ]
         }
       ]
     }
     
     
     productList = [
       ProductModel(
         id: 123,
         name: "Rau muống",
         unitName: "kg",
         unitValue: "1",
         imageUrl: "http://example.com/rau_muong.jpg",
         description: "Rau muống tươi, sạch",
         category: "Rau củ",
         brand: "Organic Farm",
         stock: 100,
         avgRating: 4.5,
         totalSold: 200,
         nutritionValues: [NutritionValue(nutritionId: 1, value: 100)]
       ),
       ProductModel(
         id: 125,
         name: "Táo Fuji",
         unitName: "kg",
         unitValue: "1",
         imageUrl: "http://example.com/tao_fuji.jpg",
         description: "Táo Fuji nhập khẩu",
         category: "Trái cây",
         brand: "Fuji Japan",
         stock: 50,
         avgRating: 4.8,
         totalSold: 150,
         nutritionValues: [NutritionValue(nutritionId: 3, value: 80)]
       ),
       ProductModel(
         id: 127,
         name: "Cá hồi",
         unitName: "kg",
         unitValue: "0.5",
         imageUrl: "http://example.com/ca_hoi.jpg",
         description: "Cá hồi tươi, giàu omega-3",
         category: "Hải sản",
         brand: "Norway Sea",
         stock: 20,
         avgRating: 4.9,
         totalSold: 80,
         nutritionValues: [NutritionValue(nutritionId: 4, value: 200)]
       ),
       ProductModel(
         id: 129,
         name: "Sữa tươi",
         unitName: "lít",
         unitValue: "1",
         imageUrl: "http://example.com/sua_tuoi.jpg",
         description: "Sữa tươi nguyên chất",
         category: "Sữa",
         brand: "Vinamilk",
         stock: 200,
         avgRating: 4.7,
         totalSold: 300,
         nutritionValues: [NutritionValue(nutritionId: 5, value: 120)]
       )
     ]
     
     productOffers = [
       123: (
         productDict: [
           "productId": 123,
           "productName": "Rau muống",
           "originalPrice": 20000,
           "offerPrice": 14000,
           "discountPercentage": 30.0
         ],
         offerDict: [
           "startDate": "2025-06-22",
           "endDate": "2025-07-01",
           "discountPercentage": 30.0
         ]
       ),
       125: (
         productDict: [
           "productId": 125,
           "productName": "Táo Fuji",
           "originalPrice": 30000,
           "offerPrice": 24000,
           "discountPercentage": 20.0
         ],
         offerDict: [
           "startDate": "2025-06-20",
           "endDate": "2025-06-30",
           "discountPercentage": 20.0
         ]
       ),
       127: (
         productDict: [
           "productId": 127,
           "productName": "Cá hồi",
           "originalPrice": 200000,
           "offerPrice": 170000,
           "discountPercentage": 15.0
         ],
         offerDict: [
           "startDate": "2025-06-22",
           "endDate": "2025-07-01",
           "discountPercentage": 15.0
         ]
       ),
       129: (
         productDict: [
           "productId": 129,
           "productName": "Sữa tươi",
           "originalPrice": 25000,
           "offerPrice": 22500,
           "discountPercentage": 10.0
         ],
         offerDict: [
           "startDate": "2025-06-25",
           "endDate": "2025-07-05",
           "discountPercentage": 10.0
         ]
       )
     ]
     */
    
    func serviceCallExclusiveOffers() {
        let timestamp = String(Date().timeIntervalSince1970)
        let pathWithTimestamp = "\(Globs.SV_EXCLUSIVE_OFFER)/active?t=\(timestamp)"
        
        ServiceCall.get(path: pathWithTimestamp) { responseObj in
            if let response = responseObj as? NSDictionary {
                if let content = response.value(forKey: "content") as? NSArray {
                    var productOffers: [Int: (productDict: NSDictionary, offerDict: NSDictionary)] = [:]
                    /* productOffers = [
                       123: (
                         productDict: ["productId": 123, "productName": "Rau muống", "originalPrice": 20000, "offerPrice": 14000, "discountPercentage": 30.0],
                         offerDict: ["startDate": "2025-06-22", "endDate": "2025-07-01", "discountPercentage": 30.0]
                       )
                     ] */
                    for offer in content { // Duyệt qua từng offer (mỗi offer là một ưu đãi).
                        guard let offerDict = offer as? NSDictionary,
                              let startDateStr = offerDict["startDate"] as? String,
                              let endDateStr = offerDict["endDate"] as? String,
                              let productsArray = offerDict["products"] as? NSArray else { continue } // bỏ qua và tiếp tục chạy, nếu gặp obj lỗi
                        
                        for product in productsArray {
                            guard let productDict = product as? NSDictionary, // productDict = {"productId": 123, ...}
                                  let productId = productDict["productId"] as? Int else { continue } // productId = 123
                            
                            // Nếu sản phẩm đã tồn tại, so sánh discountPercentage
                            if let existing = productOffers[productId] {
                                let existingDiscount = existing.offerDict["discountPercentage"] as? Double ?? 0
                                let currentDiscount = offerDict["discountPercentage"] as? Double ?? 0
                                if currentDiscount > existingDiscount {
                                    productOffers[productId] = (productDict, offerDict)
                                    /*
                                     productOffers[123] = (
                                       productDict: ["productId": 123, "productName": "Rau muống", "offerPrice": 14000, ...],
                                       offerDict: ["discountPercentage": 30.0, "startDate": "2025-06-22", ...]
                                     )
                                     */
                                }
                            } else {
                                productOffers[productId] = (productDict, offerDict) // not exit
                            }
                        } // for 2
                    } // for 1
                    
                   
                    // Tạo danh sách sản phẩm từ productOffers
                    var products: [ProductModel] = []
                    for (_, (productDict, offerDict)) in productOffers {
                        var mappedDict: [String: Any] = [:]
                        // Sửa ánh xạ để khớp với các key mà ProductModel mong đợi
                        mappedDict["id"] = productDict["productId"]
                        mappedDict["name"] = productDict["productName"]
                        mappedDict["price"] = productDict["originalPrice"]
                        mappedDict["offerPrice"] = productDict["offerPrice"]
                        mappedDict["discountPercentage"] = productDict["discountPercentage"]
                        mappedDict["startDate"] = offerDict["startDate"]
                        mappedDict["endDate"] = offerDict["endDate"]
                        /*
                         mappedDict = [
                           "id": 123,
                           "name": "Rau muống",
                           "price": 20000,
                           "offerPrice": 14000,
                           "discountPercentage": 30.0,
                           "startDate": "2025-06-22",
                           "endDate": "2025-07-01"
                         ]
                         */
                        
                        if let productId = productDict["productId"] as? Int,
                           let matchingProduct = self.productList.first(where: { $0.id == productId }) {
                            mappedDict["unitName"] = matchingProduct.unitName
                            mappedDict["unitValue"] = matchingProduct.unitValue
                            mappedDict["imageUrl"] = matchingProduct.imageUrl
                            mappedDict["description"] = matchingProduct.description
                            mappedDict["category"] = matchingProduct.category
                            mappedDict["brand"] = matchingProduct.brand
                            mappedDict["stock"] = matchingProduct.stock
                            mappedDict["avgRating"] = matchingProduct.avgRating
                            mappedDict["totalSold"] = matchingProduct.totalSold
                            mappedDict["nutritionValues"] = matchingProduct.nutritionValues.map {
                                ["nutritionId": $0.nutritionId, "value": String($0.value)]
                            }
                            /*
                             mappedDict["unitName"] = "kg"
                             mappedDict["imageUrl"] = "http://example.com/rau_muong.jpg"
                             // ...
                             mappedDict["nutritionValues"] = [["nutritionId": 1, "value": "100"], ...]
                             */
                        } else {
                            // Nếu không tìm thấy sản phẩm trong productList, sử dụng giá trị mặc định
                            mappedDict["unitName"] = ""
                            mappedDict["unitValue"] = ""
                            mappedDict["imageUrl"] = ""
                            mappedDict["description"] = ""
                            mappedDict["category"] = ""
                            mappedDict["brand"] = ""
                            mappedDict["stock"] = 0
                            mappedDict["avgRating"] = 0.0
                            mappedDict["totalSold"] = 0
                            mappedDict["nutritionValues"] = []
                        }
                        let product = ProductModel(dict: mappedDict as NSDictionary)
                        products.append(product)
                    } // for 1
                    
                    DispatchQueue.main.async {
                        self.exclusiveOfferList = products.sorted { $0.id < $1.id }
                        // In log để kiểm tra danh sách sản phẩm
                        print("Exclusive Offer List: \(self.exclusiveOfferList.map { "\($0.id) - \($0.name)" })")
                        //Exclusive Offer List: ["123 - Rau muống"]
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
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }

    func fetchCategories() {
        ServiceCall.get(path: Globs.SV_CATEGORIES) { responseObj in
            if let response = responseObj as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.categories = response.map { CategoryModel(dict: $0) }
                    self.updateCategorizedProducts()
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

    func toggleShare() {
        self.share.toggle()
    }
}
/*
 productList = [
   ProductModel(
     id: 123,
     name: "Rau muống",
     unitName: "kg",
     unitValue: "1",
     imageUrl: "http://example.com/rau_muong.jpg",
     description: "Rau muống tươi, sạch",
     category: "Rau củ",
     brand: "Organic Farm",
     stock: 100,
     avgRating: 4.5,
     totalSold: 200,
     nutritionValues: [
       NutritionValue(nutritionId: 1, value: 100), // Vitamin A
       NutritionValue(nutritionId: 2, value: 50)   // Vitamin C
     ]
   ),
   ProductModel(
     id: 125,
     name: "Táo Fuji",
     unitName: "kg",
     unitValue: "1",
     imageUrl: "http://example.com/tao_fuji.jpg",
     description: "Táo Fuji nhập khẩu, ngọt giòn",
     category: "Trái cây",
     brand: "Fuji Japan",
     stock: 50,
     avgRating: 4.8,
     totalSold: 150,
     nutritionValues: [
       NutritionValue(nutritionId: 3, value: 80) // Fiber
     ]
   ),
   ProductModel(
     id: 127,
     name: "Cá hồi",
     unitName: "kg",
     unitValue: "0.5",
     imageUrl: "http://example.com/ca_hoi.jpg",
     description: "Cá hồi tươi, giàu omega-3",
     category: "Hải sản",
     brand: "Norway Sea",
     stock: 20,
     avgRating: 4.9,
     totalSold: 80,
     nutritionValues: [
       NutritionValue(nutritionId: 4, value: 200) // Omega-3
     ]
   )
 ]
 */
