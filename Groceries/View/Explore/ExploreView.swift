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
                } // H1
                .padding(.top, .topInsets)
                
                // Thanh tìm kiếm và nút bộ lọc
                HStack {
                    SearchTextField(placeholder: "Search by name", txt: $explorVM.txtSearch)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                        .offset(y: animateHeader ? 0 : -50)
                        .opacity(animateHeader ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateHeader)
                        .onChange(of: explorVM.txtSearch) { newValue in // explorVM.txtSearch = "Apple", newValue = "Apple".
                            explorVM.searchProducts(
                                name: newValue,
                                categoryId: explorVM.selectedCategories.first, // Chỉ lấy danh mục đầu tiên
                                brands: explorVM.selectedBrands.isEmpty ? nil : explorVM.selectedBrands
                                /*
                                 newValue = "Apple".
                                 
                                 explorVM.selectedCategories = [1] (danh mục Fresh Fruits & Vegetable).
                                 explorVM.selectedCategories.first = 1.
                                 searchProducts nhận categoryId: 1 | API: GET /api/products?name=Apple&categoryId=1.
                                 Kết quả: Chỉ trả về sản phẩm "Apple" trong danh mục Fresh Fruits & Vegetable.
                                 
                                 explorVM.selectedBrands = ["BrandA"]
                                 */
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
                } //H2
                
                /*
                 Hiển thị danh sách sản phẩm nếu có tìm kiếm hoặc bộ lọc
                 Kểm tra Có sản phẩm tìm kiếm (products không rỗng) và thanh tìm kiếm có nội dung || Hoặc có danh mục được chọn từ bộ lọc || Hoặc có thương hiệu được chọn
                 Người dùng nhập "Apple" → explorVM.txtSearch = "Apple", explorVM.products = [ProductModel(id: 5, name: "Apple", ...)].
                 Điều kiện: !products.isEmpty = true và !txtSearch.isEmpty = true → Khối if chạy.
                 */
                if (!explorVM.products.isEmpty && !explorVM.txtSearch.isEmpty) || !explorVM.selectedCategories.isEmpty || !explorVM.selectedBrands.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(explorVM.products, id: \.id) { product in // { "id": 5, "name": "Apple", "price": 2.50, ... }
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
                } else { // Không có sản phẩm tìm kiếm, không có từ khóa tìm kiếm, không có danh mục/thương hiệu được chọn
                    // Hiển thị danh sách danh mục
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(explorVM.listArr.indices, id: \.self) { index in
                                let cObj = explorVM.listArr[index] // index = 0... → cObj = ExploreCategoryModel(cat_id: 1, cat_name: "Fresh Fruits & Vegetable", ...).
                                NavigationLink(destination: ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: cObj))) {
                                    ExploreCategoryCell(cObj: cObj)
                                        .aspectRatio(0.95, contentMode: .fill)
                                        .offset(x: animateCells ? 0 : -50)
                                        .opacity(animateCells ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: animateCells)
                                }
                            } // For
                        } // Lazy
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, .bottomInsets + 60)
                    } // Scroll
                }
            } // Vstack
        }// Zstack
        .ignoresSafeArea()
        .onAppear {
            animateHeader = true
            animateCells = true
            explorVM.searchProducts(name: nil, categoryId: nil, brands: nil)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView(isPresented: $showFilterSheet, viewModel: explorVM)
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

/*
 
 Bước thực thi:
 Dòng 1: Người dùng nhập "Apple" → explorVM.txtSearch = "Apple", .onChange kích hoạt với newValue = "Apple".
 Dòng 2: Gọi explorVM.searchProducts.
 Dòng 3: Truyền name: "Apple".
 Dòng 4: explorVM.selectedCategories = [1], nên categoryId: 1.
 Dòng 5: explorVM.selectedBrands = [], nên brands: nil.
 Dòng 6: Hoàn thành lời gọi searchProducts(name: "Apple", categoryId: 1, brands: nil).
 API: GET /api/products?name=Apple&categoryId=1.
 Kết quả: explorVM.products = [ProductModel(id: 5, name: "Apple", ...)].
 Dòng 7: Kết thúc .onChange, giao diện cập nhật để hiển thị sản phẩm Apple.
 Giao diện:
 Thanh tìm kiếm: [Apple].
 Lưới sản phẩm (khối if trong ExploreView): [Apple $2.50]
 
 
 
 GET /api/categories : explorVM.listArr
 {
   "data": {
     "categories": [
       { "cat_id": 1, "cat_name": "Fresh Fruits & Vegetable", "image": "https://example.com/assets/images/fruits_veg.jpg", "color": "53B175" },
       { "cat_id": 2, "cat_name": "Beverages", "image": "https://example.com/assets/images/beverages.jpg", "color": "FF5733" },
       { "cat_id": 3, "cat_name": "Dairy Products", "image": "https://example.com/assets/images/dairy.jpg", "color": "FFC107" },
       { "cat_id": 4, "cat_name": "Bakery", "image": "https://example.com/assets/images/bakery.jpg", "color": "4CAF50" },
       { "cat_id": 5, "cat_name": "Snacks", "image": "https://example.com/assets/images/snacks.jpg", "color": "9C27B0" }
     ],
     "count": 5
   }
 }
 
 
 explorVM.listArr = [
   ExploreCategoryModel(cat_id: 1, cat_name: "Fresh Fruits & Vegetable", image: "...", color: "53B175"),
   ExploreCategoryModel(cat_id: 2, cat_name: "Beverages", image: "...", color: "FF5733"),
   ExploreCategoryModel(cat_id: 3, cat_name: "Dairy Products", image: "...", color: "FFC107"),
   ExploreCategoryModel(cat_id: 4, cat_name: "Bakery", image: "...", color: "4CAF50"),
   ExploreCategoryModel(cat_id: 5, cat_name: "Snacks", image: "...", color: "9C27B0")
 ]
 
 
 
 
 
 {
   "data": {
     "products": [
       {
         "id": 5,
         "name": "Apple",
         "price": 2.50,
         "image": "https://example.com/assets/images/apple.jpg",
         "description": "Fresh and juicy apples",
         "stock": 100,
         "discountPercentage": 20.0,
         "originalPrice": 3.00,
         "startDate": "2025-07-01T00:00:00Z",
         "endDate": "2025-07-15T23:59:59Z",
         "brand": "BrandA"
       },
       {
         "id": 2,
         "name": "Banana",
         "price": 1.50,
         "image": "https://example.com/assets/images/banana.jpg",
         "description": "Ripe yellow bananas",
         "stock": 150,
         "discountPercentage": 10.0,
         "originalPrice": 1.67,
         "startDate": "2025-07-10T00:00:00Z",
         "endDate": "2025-07-20T23:59:59Z",
         "brand": "BrandB"
       },
       {
         "id": 7,
         "name": "Orange",
         "price": 2.00,
         "image": "https://example.com/assets/images/orange.jpg",
         "description": "Sweet and tangy oranges",
         "stock": 80,
         "discountPercentage": null,
         "originalPrice": null,
         "startDate": null,
         "endDate": null,
         "brand": "BrandA"
       },
       {
         "id": 8,
         "name": "Mango",
         "price": 3.00,
         "image": "https://example.com/assets/images/mango.jpg",
         "description": "Juicy tropical mangoes",
         "stock": 50,
         "discountPercentage": 15.0,
         "originalPrice": 3.53,
         "startDate": "2025-07-05T00:00:00Z",
         "endDate": "2025-07-25T23:59:59Z",
         "brand": "BrandC"
       }
     ],
     "count": 4
   }
 }
 */
