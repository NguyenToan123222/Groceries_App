import Foundation


struct ProductModel: Identifiable, Equatable, Hashable {
    var id: Int
    var name: String
    var price: Double
    var stock: Int
    var unitName: String
    var unitValue: String
    var description: String?
    var imageUrl: String?
    var category: String?
    var brand: String?
    var offerPrice: Double?
    var isDiscountValid: Bool
    var avgRating: Double?
    var startDate: Date?
    var endDate: Date?
    var totalSold: Int?
    var nutritionValues: [NutritionValueModel]
    var discountPercentage: Double?

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.price = dict.value(forKey: "price") as? Double ?? 0.0
        self.stock = dict.value(forKey: "stock") as? Int ?? 0
        self.unitName = dict.value(forKey: "unitName") as? String ?? ""
        self.unitValue = dict.value(forKey: "unitValue") as? String ?? ""
        self.description = dict.value(forKey: "description") as? String
        self.imageUrl = dict.value(forKey: "imageUrl") as? String
        self.category = dict.value(forKey: "category") as? String
        self.brand = dict.value(forKey: "brand") as? String
        self.avgRating = dict.value(forKey: "avgRating") as? Double
        self.totalSold = dict.value(forKey: "totalSold") as? Int

        if let nutritionArray = dict.value(forKey: "nutritionValues") as? [NSDictionary] {
            self.nutritionValues = nutritionArray.map { nutritionDict in
                let valueString = nutritionDict.value(forKey: "value") as? String ?? "0.0"
                let value = Double(valueString) ?? 0.0
                return NutritionValueModel(
                    nutritionId: nutritionDict.value(forKey: "nutritionId") as? Int ?? 0,
                    value: value
                )
            }
        } else {
            self.nutritionValues = []
        }

        // Ánh xạ offerPrice và discountPercentage
        if let offerDict = dict.value(forKey: "offer") as? NSDictionary {
            self.offerPrice = offerDict.value(forKey: "offerPrice") as? Double
            self.discountPercentage = offerDict.value(forKey: "discountPercentage") as? Double
            self.startDate = (offerDict.value(forKey: "startDate") as? String)?.iso8601Date()
            self.endDate = (offerDict.value(forKey: "endDate") as? String)?.iso8601Date()
        } else {
            self.offerPrice = dict.value(forKey: "offerPrice") as? Double
            self.discountPercentage = dict.value(forKey: "discountPercentage") as? Double
            self.startDate = (dict.value(forKey: "startDate") as? String)?.iso8601Date()
            self.endDate = (dict.value(forKey: "endDate") as? String)?.iso8601Date()
        }

        // Sửa logic isDiscountValid để không yêu cầu startDate và endDate
        let currentDate = Date()
        if startDate != nil && endDate != nil {
            // Nếu có startDate và endDate (dành cho các API như /api/products hoặc /api/cart)
            self.isDiscountValid = (offerPrice != nil && discountPercentage != nil) &&
                                  (startDate! <= currentDate && currentDate <= endDate! && offerPrice! < price)
        } else {
            // Nếu không có startDate và endDate (dành cho API /api/favorites)
            self.isDiscountValid = (offerPrice != nil && discountPercentage != nil && offerPrice! < price)
        }
    }

    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
/*
 {
   "id": 1,
   "name": "Táo Fuji",
   "price": 100.0,
   "stock": 50,
   "unitName": "kg",
   "unitValue": "1kg",
   "description": "Táo nhập khẩu",
   "imageUrl": "https://example.com/apple.jpg",
   "category": "Trái cây",
   "brand": "Fuji",
   "avgRating": 4.5,
   "totalSold": 200,
   "nutritionValues": [
     {"nutritionId": 1, "value": "10.5"},
     {"nutritionId": 2, "value": "20.0"}
   ],
   "offer": {
     "offerPrice": 90.0,
     "discountPercentage": 10.0,
     "startDate": "2025-05-01T00:00:00Z",
     "endDate": "2025-05-31T23:59:59Z"
   }
 }
 */
