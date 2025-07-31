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
    
    // Danh sách 25 màu khác nhau (mã hex)
    private let categoryColors: [String] = [
        "FF6F61", // Coral
        "6B5B95", // Purple
        "88B04B", // Olive Green
        "F7CAC9", // Light Pink
        "92A8D1", // Light Purple
        "F4A261", // Sandy Brown
        "E2D4B7", // Beige
        "D4A5A5", // Dusty Rose
        "9B97B2", // Lilac
        "A5D6A7", // Pale Green
        "F28F38", // Tangerine
        "C5E1A5", // Light Green
        "FFCCBC", // Peach
        "90CAF9", // Light Blue
        "FFE082", // Light Yellow
        "B0BEC5", // Light Gray
        "F06292", // Pink
        "81D4FA", // Sky Blue
        "AED581", // Lime Green
        "FFAB91", // Light Coral
        "80DEEA", // Cyan
        "FFF59D", // Pale Yellow
        "B39DDB", // Lavender
        "FF8A65", // Deep Orange
        "C5CAE9", // Light Indigo
    ]
    
    
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
                    self.listArr = categories.enumerated().map { (index, category) in
                        /*
                         categories.enumerated(): Trả về cặp (index, category) cho mỗi phần tử (index từ 0).
                         map { ... }: Chuyển mỗi cặp (index, category) thành ExploreCategoryModel.
                         
                         Gán assetImageName:
                         index = 0 → "1".
                         index = 1 → "2".
                         Gán color:
                         index = 0 → "FF6F61".
                         index = 1 → "6B5B95".
                         */
                        let assetImageName = index < 25 ? "\(index + 1)" : nil // img
                        // Gán màu từ danh sách categoryColors, lặp lại nếu vượt quá số màu
                        let color = self.categoryColors[index % self.categoryColors.count]
                        return ExploreCategoryModel(
                            dict: [
                                "cat_id": category.id,
                                "cat_name": category.name,
                                "color": color, // Gán màu khác nhau
                                "assetImageName": assetImageName as Any
                                /*
                                 [
                                     ExploreCategoryModel(id: 1, name: "Trái cây", color: "FF6F61", assetImageName: "1"),
                                     ExploreCategoryModel(id: 2, name: "Rau củ", color: "6B5B95", assetImageName: "2")
                                 ]
                                 */
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
    
    func searchProducts(name: String?, categoryId: Int?, brands: [String]?) {
        var queryItems: [String] = []
        if let name = name, !name.isEmpty {
            queryItems.append("name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let categoryId = categoryId {
            queryItems.append("categoryId=\(categoryId)") // Sử dụng categoryId thay vì categoryIds
        }
        if let brands = brands, !brands.isEmpty {
            queryItems.append("brands=\(brands.joined(separator: ","))") // ["Sunrise", "Organic"] → "Sunrise,Organic"
        }
        
        let queryString = queryItems.joined(separator: "&")// "name=T%C3%A1o&categoryId=1&brands=Sunrise,Organic".
        let path = queryString.isEmpty ? "\(Globs.SV_FILTER_PRODUCTS)" : "\(Globs.SV_FILTER_PRODUCTS)?\(queryString)"
        /*
         Nếu rỗng: path = Globs.SV_FILTER_PRODUCTS (ví dụ: /api/products).
         Nếu không rỗng: path = Globs.SV_FILTER_PRODUCTS?queryString (ví dụ: /api/products?name=T%C3%A1o&categoryId=1).
         */
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
