//
//  ProductListView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 4/11/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var homeVM = HomeViewModel.shared
    
    var body: some View {
        NavigationView { // Đảm bảo ProductListView nằm trong NavigationView
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        if homeVM.productList.isEmpty {
                            Text("No products available")
                                .font(.customfont(.medium, fontSize: 16))
                                .foregroundColor(.gray)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 20)
                        } else {
                            ForEach(homeVM.categories, id: \.id) { category in
                                let productsInCategory = homeVM.productList.filter { $0.category == category.name }
                                // productsInCategory = [Product(id: 1, name: "Apple", category: "Fruits", price: 2.99), Product(id: 2, name: "Banana", category: "Fruits", price: 1.5)].
                                if !productsInCategory.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text(category.name)
                                            .font(.customfont(.bold, fontSize: 20))
                                            .foregroundColor(.primaryText)
                                            .padding(.horizontal, 20)
                                            .padding(.top, 5)

                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 15) {
                                                ForEach(productsInCategory, id: \.id) { product in
                                                    NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                                        ProductCell(pObj: product, didAddCart: {
                                                            CartViewModel.shared.serviceCallAddToCart(prodId: product.id, qty: 1) { isDone, msg in
                                                                homeVM.errorMessage = msg
                                                                homeVM.showError = true
                                                            }
                                                        })
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 20) // LazyHStack
                                            .padding(.vertical, 5) //
                                        }
                                    }
                                }
                            } // for

                            let uncategorizedProducts = homeVM.productList.filter { $0.category == nil || $0.category?.isEmpty == true }
                            if !uncategorizedProducts.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Uncategorized")
                                        .font(.customfont(.bold, fontSize: 20))
                                        .foregroundColor(.primaryText)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 5)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 15) {
                                            ForEach(uncategorizedProducts, id: \.id) { product in
                                                NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                                    ProductCell(pObj: product, didAddCart: {
                                                        CartViewModel.shared.serviceCallAddToCart(prodId: product.id, qty: 1) { isDone, msg in
                                                            homeVM.errorMessage = msg
                                                            homeVM.showError = true
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                    }
                                }
                            }
                        } // else
                        
                    } // Lazy
                    .padding(.bottom, .bottomInsets + 20)
                }
            }
            .navigationTitle("All Products")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $homeVM.showError, content: {
                Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }

}
#Preview {
    NavigationView {
        ProductListView()
    }
}
/* {
 "categories": [
   {"id": 1, "name": "Fruits"},
   {"id": 2, "name": "Vegetables"}
 ],
 "products": [
   {"id": 1, "name": "Apple", "category": "Fruits", "price": 2.99},
   {"id": 2, "name": "Banana", "category": "Fruits", "price": 1.5},
   {"id": 3, "name": "Carrot", "category": "Vegetables", "price": 1.99},
   {"id": 4, "name": "Orange", "price": 2.49} // Không danh mục
 ]
}*/
