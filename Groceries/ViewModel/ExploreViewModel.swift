//
//  ExploreViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI

class ExploreViewModel: ObservableObject {
    static var shared: ExploreViewModel = ExploreViewModel()
    
    @Published var txtSearch: String = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var listArr: [ExploreCategoryModel] = [] // Danh sách danh mục
    @Published var products: [ProductModel] = [] // Danh sách sản phẩm tìm kiếm
    
    // Bộ lọc danh mục và thương hiệu
    @Published var selectedCategories: [Int] = [] // ID của danh mục đã chọn
    @Published var selectedBrands: [String] = [] // Tên thương hiệu đã chọn
    @Published var brands: [String] = [] // Danh sách thương hiệu (lấy từ backend)
    
    init() {
        fetchCategories()
        fetchBrands()
        serviceCallList()
    }
    
    // MARK: - Service Calls
    
    func serviceCallList() {
        ServiceCall.post(parameter: [:], path: Globs.SV_EXPLORE_LIST) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response.value(forKey: KKey.status) as? String ?? "" == "1" {
                    self.listArr = (response.value(forKey: KKey.payLoad) as? NSArray ?? []).map { obj in
                        return ExploreCategoryModel(dict: obj as? NSDictionary ?? [:])
                    }
                } else {
                    self.errorMessage = response.value(forKey: KKey.message) as? String ?? "Fail"
                    self.showError = true
                }
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Fail"
            self.showError = true
        }
    }
    
    func fetchCategories() {
        ServiceCall.get(path: Globs.SV_CATEGORIES) { responseObj in
            if let response = responseObj as? [NSDictionary] {
                DispatchQueue.main.async {
                    let categories = response.map { CategoryModel(dict: $0) }
                    // Chuyển đổi CategoryModel thành ExploreCategoryModel
                    self.listArr = categories.map { category in
                        ExploreCategoryModel(
                            dict: [
                                "cat_id": category.id,
                                "cat_name": category.name,
                                "color": "53B175" // Mặc định màu (có thể thay đổi nếu backend cung cấp)
                            ]
                        )
                    }
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
        ServiceCall.get(path: Globs.SV_BRANDS) { responseObj in
            if let response = responseObj as? [NSDictionary] {
                DispatchQueue.main.async {
                    let brands = response.map { BrandModel(dict: $0) }
                    self.brands = brands.map { $0.name }
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
    
    func searchProducts(name: String?, categoryIds: [Int]?, brands: [String]?) {
        var queryItems: [String] = []
        if let name = name, !name.isEmpty {
            queryItems.append("name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let categoryIds = categoryIds, !categoryIds.isEmpty {
            queryItems.append("categoryIds=\(categoryIds.map { String($0) }.joined(separator: ","))")
        }
        if let brands = brands, !brands.isEmpty {
            queryItems.append("brands=\(brands.joined(separator: ","))")
        }
        
        let queryString = queryItems.joined(separator: "&")
        let path = queryString.isEmpty ? "\(Globs.SV_FILTER_PRODUCTS)" : "\(Globs.SV_FILTER_PRODUCTS)?\(queryString)"
        
        print("Search URL: \(path)")
        
        ServiceCall.get(path: path) { responseObj in
            print("Search Response: \(String(describing: responseObj))")
            if let response = responseObj as? NSDictionary,
               let content = response["content"] as? [NSDictionary] {
                DispatchQueue.main.async {
                    self.products = content.map { ProductModel(dict: $0) }
                    print("Search Results: \(self.products.map { $0.name })")
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
