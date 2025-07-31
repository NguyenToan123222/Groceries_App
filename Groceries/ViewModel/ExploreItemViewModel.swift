//
//  ExploreItemViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI

class ExploreItemViewModel: ObservableObject {
    @Published var cObj: ExploreCategoryModel
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var listArr: [ProductModel] = []
    
    init(catObj: ExploreCategoryModel) {
        self.cObj = catObj
        serviceCallList()
    }
    
    func serviceCallList() {
        // Lấy danh sách sản phẩm từ HomeViewModel
        let productsInCategory = HomeViewModel.shared.productList.filter { $0.category == cObj.name } // Trái cây
        self.listArr = productsInCategory
        // listArr = products = [Táo, Chuối]
        
        // Đồng thời gọi API để cập nhật dữ liệu mới nếu cần
        ExploreViewModel.shared.searchProducts(name: nil, categoryId: cObj.id, brands: nil)
    }
}

/*
 // Giả định HomeViewModel
 class HomeViewModel {
     static let shared = HomeViewModel()
     var productList: [ProductModel] = [
         ProductModel(id: 456, name: "Táo", category: "Trái cây", price: 40.0),
         ProductModel(id: 457, name: "Chuối", category: "Trái cây", price: 10.0),
         ProductModel(id: 458, name: "Cà rốt", category: "Rau củ", price: 20.0)
     ]
 }
 let category = ExploreCategoryModel(id: 1, name: "Trái cây")
 let products = HomeViewModel.shared.productList.filter { $0.category == category.name }
 // products = [Táo, Chuối]
 */
