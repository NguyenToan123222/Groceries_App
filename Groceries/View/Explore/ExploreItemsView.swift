//
//  ExploreItemsView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI

struct ExploreItemsView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var itemsVM: ExploreItemViewModel //khai báo kiểu để nơi khác cung cấp dữ liệuu
    
    var columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) { // Đặt spacing = 0 để loại bỏ khoảng cách mặc định giữa các thành phần trong VStack
                // Tiêu đề và nút quay lại
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    
                    Text(itemsVM.cObj.name)
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(minWidth: 0, maxHeight: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    Button {
                        // Nút bộ lọc (có thể thêm nếu cần)
                    } label: {
                        Image("filter_ic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                } // H
                .padding(.top, .topInsets - 10) // Giảm khoảng cách với topInsets
                .padding(.horizontal, 20)
                
                // Danh sách sản phẩm
                ScrollView {
                    if itemsVM.listArr.isEmpty {
                        Text("No products available in this category")
                            .font(.customfont(.medium, fontSize: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(itemsVM.listArr, id: \.id) { pObj in // itemsVM.listArr = [ProductModel(id: 5, name: "Apple", price: 2.50, ...), ProductModel(id: 1, name: "Fresh Milk", price: 3.00, ...)]
                                NavigationLink(destination: ProductDetailView(productId: pObj.id)) {
                                    ProductCell(pObj: pObj, didAddCart: {
                                        CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                            itemsVM.errorMessage = msg
                                            itemsVM.showError = true
                                        }
                                    }) // productcell
                                } // Navi
                            } // For
                        } // Lazy
                        .padding(.horizontal, 10)
                        .padding(.top, 5) // Chỉ giữ padding phía trên, bỏ padding phía dưới
                        .padding(.bottom, .bottomInsets + 30)
                    }
                }
            } // V
        } // Z
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .alert(isPresented: $itemsVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(itemsVM.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
struct ExploreItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: ExploreCategoryModel(dict: [
                "cat_id": 1,
                "cat_name": "Fresh Fruits & Vegetable",
                "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
                "color": "53B175"
            ])))
        }
    }
}

/*
 {
   "data": {
     "categoryId": 1,
     "categoryName": "Fresh Fruits & Vegetable",
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
         "endDate": "2025-07-15T23:59:59Z"
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
         "endDate": "2025-07-20T23:59:59Z"
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
         "endDate": null
       }
     ],
     "count": 3
   }
 }
 */
