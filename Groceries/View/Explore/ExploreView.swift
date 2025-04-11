//
//  ExploreView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 8/12/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject var explorVM = ExploreViewModel.shared
    @State private var animateBackground = false
    @State private var animateHeader = false
    @State private var animateCells = false
    @State private var showFilterSheet = false
    
    var columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animateBackground)
                .onAppear {
                    animateBackground = true
                }
            
            VStack {
                // Tiêu đề và thanh tìm kiếm
                HStack {
                    Spacer()
                    
                    Text("Find Products")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)
                        .offset(y: animateHeader ? 0 : -50)
                        .opacity(animateHeader ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: animateHeader)
                    
                    Spacer()
                }
                .padding(.top, .topInsets)
                
                // Thanh tìm kiếm và nút bộ lọc
                HStack {
                    SearchTextField(placeholder: "Search by name", txt: $explorVM.txtSearch)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                        .offset(y: animateHeader ? 0 : -50)
                        .opacity(animateHeader ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateHeader)
                        .onChange(of: explorVM.txtSearch) { newValue in
                            explorVM.searchProducts(
                                name: newValue,
                                categoryIds: explorVM.selectedCategories.isEmpty ? nil : explorVM.selectedCategories,
                                brands: explorVM.selectedBrands.isEmpty ? nil : explorVM.selectedBrands
                            )
                        }
                    
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.trailing, 20)
                }
                
                // Hiển thị danh sách sản phẩm nếu có tìm kiếm hoặc bộ lọc
                if (!explorVM.products.isEmpty && !explorVM.txtSearch.isEmpty) || !explorVM.selectedCategories.isEmpty || !explorVM.selectedBrands.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(explorVM.products, id: \.id) { product in
                                NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                    ProductCell(pObj: product, didAddCart: {
                                        CartViewModel.shared.serviceCallAddToCart(prodId: product.id, qty: 1) { isDone, msg in
                                            explorVM.errorMessage = msg
                                            explorVM.showError = true
                                        }
                                    })
                                    .offset(x: animateCells ? 0 : -50)
                                    .opacity(animateCells ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(Double(explorVM.products.firstIndex(of: product) ?? 0) * 0.1), value: animateCells)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, .bottomInsets + 60)
                    }
                } else {
                    // Hiển thị danh sách danh mục
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(explorVM.listArr.indices, id: \.self) { index in
                                let cObj = explorVM.listArr[index]
                                NavigationLink(destination: ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: cObj))) {
                                    ExploreCategoryCell(cObj: cObj)
                                        .aspectRatio(0.95, contentMode: .fill)
                                        .offset(x: animateCells ? 0 : -50)
                                        .opacity(animateCells ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: animateCells)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, .bottomInsets + 60)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateHeader = true
            animateCells = true
            explorVM.searchProducts(name: nil, categoryIds: nil, brands: nil)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView(isPresented: $showFilterSheet, viewModel: explorVM)
        }
        .alert(isPresented: $explorVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(explorVM.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreView()
        }
    }
}
