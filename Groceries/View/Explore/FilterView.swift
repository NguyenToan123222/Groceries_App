//
//  FilterView.swift
//  Groceries_Shop
//

import SwiftUI

struct FilterView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ExploreViewModel
    
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
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Phần danh mục
                        Text("Category")
                            .font(.customfont(.bold, fontSize: 16))
                            .padding(.horizontal)
                        
                        ForEach(viewModel.listArr, id: \.id) { category in
                            HStack {
                                Image(systemName: viewModel.selectedCategories.contains(category.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.selectedCategories.contains(category.id) ? .green : .gray)
                                Text(category.name)
                                    .font(.customfont(.medium, fontSize: 14))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                if viewModel.selectedCategories.contains(category.id) {
                                    viewModel.selectedCategories.removeAll { $0 == category.id }
                                } else {
                                    viewModel.selectedCategories.append(category.id)
                                }
                            }
                        }
                        
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
                }
                
                // Nút xóa bộ lọc
                Button(action: {
                    viewModel.selectedCategories = []
                    viewModel.selectedBrands = []
                    viewModel.searchProducts(
                        name: viewModel.txtSearch,
                        categoryIds: nil,
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
                    viewModel.searchProducts(
                        name: viewModel.txtSearch,
                        categoryIds: viewModel.selectedCategories.isEmpty ? nil : viewModel.selectedCategories,
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
            }
            .background(Color.white)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(isPresented: .constant(true), viewModel: ExploreViewModel.shared)
    }
}
