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
    
    // MARK: - Service Call
    
    func serviceCallList() {
        ExploreViewModel.shared.searchProducts(name: nil, categoryIds: [cObj.id], brands: nil)
        // Đồng bộ listArr với products từ ExploreViewModel
        self.listArr = ExploreViewModel.shared.products
    }
}
