//
//  ProductModel.swift
//  OnlineGroceriesSwiftUI
//
//  Created by CodeForAny on 04/08/23.


import SwiftUI

struct ProductModel: Identifiable, Equatable {
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
    var avgRating: Int?
    var startDate: Date?
    var endDate: Date?
    var totalSold: Int? // Thêm trường totalSold
    var nutritionValues: [NutritionValueModel]

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.name = dict.value(forKey: "name") as? String ?? ""
        // Xử lý price: có thể là String hoặc Double
        if let priceString = dict.value(forKey: "price") as? String {
            self.price = Double(priceString) ?? 0.0
        } else {
            self.price = dict.value(forKey: "price") as? Double ?? 0.0
        }
        self.stock = dict.value(forKey: "stock") as? Int ?? 0
        self.unitName = dict.value(forKey: "unitName") as? String ?? ""
        self.unitValue = dict.value(forKey: "unitValue") as? String ?? ""
        self.description = dict.value(forKey: "description") as? String
        self.imageUrl = dict.value(forKey: "imageUrl") as? String
        self.category = dict.value(forKey: "category") as? String
        self.brand = dict.value(forKey: "brand") as? String
        self.offerPrice = dict.value(forKey: "offerPrice") as? Double
        self.avgRating = dict.value(forKey: "avgRating") as? Int
        self.startDate = (dict.value(forKey: "startDate") as? String)?.iso8601Date()
        self.endDate = (dict.value(forKey: "endDate") as? String)?.iso8601Date()
        self.totalSold = dict["totalSold"] as? Int // Thêm totalSold

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
    }

    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id == rhs.id
    }
}

