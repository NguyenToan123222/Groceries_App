//
//  ProductModel.swift
//  OnlineGroceriesSwiftUI
//
//  Created by CodeForAny on 04/08/23.
//

import SwiftUI

struct ProductModel:  Identifiable, Equatable {
    var id: Int = 0
    var prodId: Int = 0
    var catId: Int = 0 // category product
    var brandId: Int = 0
    var typeId: Int = 0
    var orderId: Int = 0 // code ordered product
    var qty: Int = 0 // quantity
    var detail: String = "" // describe detail
    var name: String = ""
    var unitName: String = "" // Tên đơn vị đo (ví dụ: "kg", "lít", "hộp").
    var unitValue: String = "" // Giá trị của đơn vị đo (ví dụ: "1", "500g").
    var nutritionWeight: String = "" // Thông tin về cân nặng dinh dưỡng
    var image: String = ""
    var catName: String = "" // category name
    var typeName: String = ""
    var offerPrice: Double? // * ? *
    // Giá khuyến mãi của sản phẩm (kiểu Double? vì có thể không có khuyến mãi).
    var itemPrice: Double = 0.0 // price each pro
    var totalPrice: Double = 0.0
    var price: Double = 0 // price sale
    var startDate: Date = Date()
    var endDate: Date = Date()// date start-end of promotion
    var isFav: Bool = false // favorite
    var avgRating: Int = 0 // average of rating
    

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.prodId = dict.value(forKey: "prod_id") as? Int ?? 0
        self.catId = dict.value(forKey: "cat_id") as? Int ?? 0
        self.brandId = dict.value(forKey: "brand_id") as? Int ?? 0
        self.typeId = dict.value(forKey: "type_id") as? Int ?? 0
        self.orderId = dict.value(forKey: "order_id") as? Int ?? 0
        self.qty = dict.value(forKey: "qty") as? Int ?? 0
        self.isFav = dict.value(forKey: "is_fav") as? Int ?? 0 == 1
        self.detail = dict.value(forKey: "detail") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.unitName = dict.value(forKey: "unit_name") as? String ?? ""
        self.unitValue = dict.value(forKey: "unit_value") as? String ?? ""
        self.nutritionWeight = dict.value(forKey: "nutrition_weight") as? String ?? ""
        self.image = dict.value(forKey: "image") as? String ?? ""
        self.catName = dict.value(forKey: "cat_name") as? String ?? ""
        self.typeName = dict.value(forKey: "type_name") as? String ?? ""
        self.offerPrice = dict.value(forKey: "offer_price") as? Double
        self.price = dict.value(forKey: "price") as? Double ?? 0
        self.itemPrice = dict.value(forKey: "item_price") as? Double ?? 0
        self.totalPrice = dict.value(forKey: "total_price") as? Double ?? 0
        self.startDate = (dict.value(forKey: "start_date") as? String ?? "").stringDateToDate() ?? Date()
        self.endDate = (dict.value(forKey: "end_date") as? String ?? "").stringDateToDate() ?? Date()
        self.avgRating =  Int(dict.value(forKey: "avg_rating") as? Double ?? 0.0)
    }
    
    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id == rhs.id
    }
}
