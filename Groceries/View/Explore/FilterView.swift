//
//  FilterView.swift
//  Groceries_Shop
//

import SwiftUI

struct FilterView: View {
    
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ExploreViewModel
    
    @State private var selectedCategoryId: Int? = nil // Chỉ lưu một danh mục duy nhất
    
    var body: some View {
        NavigationView {
            VStack {
                // Tiêu đề
                HStack {
                    Spacer()
                    Text("Filters")
                        .font(.customfont(.bold, fontSize: 20))
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(10)
                    }
                } // H
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Phần danh mục
                        Text("Category")
                            .font(.customfont(.bold, fontSize: 16))
                            .padding(.horizontal)
                        
                        ForEach(viewModel.listArr, id: \.id) { category in
                            HStack {
                                Image(systemName: selectedCategoryId == category.id ? "checkmark.square.fill" : "square")
                                // Nếu selectedCategoryId = 1 và category.id = 1 → Hiển thị [✓].
                                    .foregroundColor(selectedCategoryId == category.id ? .green : .gray)
                                Text(category.name)
                                    .font(.customfont(.medium, fontSize: 14))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                if selectedCategoryId == category.id {
                                    selectedCategoryId = nil // Bỏ chọn nếu đã chọn
                                } else {
                                    selectedCategoryId = category.id // Chọn danh mục mới
                                }
                            }
                        } // For
                        
                        // Phần thương hiệu
                        Text("Brand")
                            .font(.customfont(.bold, fontSize: 16))
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        ForEach(viewModel.brands, id: \.self) { brand in
                            HStack {
                                Image(systemName: viewModel.selectedBrands.contains(brand) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.selectedBrands.contains(brand) ? .green : .gray)
                                Text(brand)
                                    .font(.customfont(.medium, fontSize: 14))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                if viewModel.selectedBrands.contains(brand) {
                                    viewModel.selectedBrands.removeAll { $0 == brand }
                                } else {
                                    viewModel.selectedBrands.append(brand)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                } // Scroll
                
                // Nút xóa bộ lọc
                Button(action: {
                    selectedCategoryId = nil
                    viewModel.selectedBrands = []
                    viewModel.searchProducts(
                        name: viewModel.txtSearch,
                        categoryId: nil,
                        brands: nil
                    )
                }) {
                    Text("Clear Filters")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Nút áp dụng bộ lọc
                Button(action: {
                    viewModel.selectedCategories = selectedCategoryId != nil ? [selectedCategoryId!] : []
                    viewModel.searchProducts(
                        name: viewModel.txtSearch,
                        categoryId: selectedCategoryId,
                        brands: viewModel.selectedBrands.isEmpty ? nil : viewModel.selectedBrands
                    )
                    isPresented = false
                }) {
                    Text("Apply Filter")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, .bottomInsets + 20)
            } // V
            .background(Color.white)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(isPresented: .constant(true), viewModel: ExploreViewModel.shared)
    }
}

/*
 {
   "data": {
     "categories": [
       { "cat_id": 1, "cat_name": "Fresh Fruits & Vegetable", "image": "...", "color": "53B175" },
       { "cat_id": 2, "cat_name": "Beverages", "image": "...", "color": "FF5733" },
       { "cat_id": 3, "cat_name": "Dairy Products", "image": "...", "color": "FFC107" },
       { "cat_id": 4, "cat_name": "Bakery", "image": "...", "color": "4CAF50" },
       { "cat_id": 5, "cat_name": "Snacks", "image": "...", "color": "9C27B0" }
     ],
     "count": 5
   }
 }
 
 {
   "data": {
     "brands": ["BrandA", "BrandB", "BrandC", "BrandD", "BrandE"],
     "count": 5
   }
 }
 
 {
   "data": {
     "products": [
       { "id": 5, "name": "Apple", "price": 2.50, "image": "...", "brand": "BrandA", ... },
       { "id": 2, "name": "Banana", "price": 1.50, "image": "...", "brand": "BrandB", ... }
     ],
     "count": 2
   }
 }
 */
