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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                
            ScrollView {
                LazyVStack(spacing: 15) {
                    if homeVM.productList.isEmpty {
                        Text("No products available")
                            .font(.customfont(.medium, fontSize: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(homeVM.productList, id: \.id) { pObj in
                            ProductCell(pObj: pObj, didAddCart: {
                                CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                    homeVM.errorMessage = msg
                                    homeVM.showError = true
                                }
                            })
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("All Products")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $homeVM.showError, content: {
            Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
        })
    }
}

#Preview {
    NavigationView { // Giữ NavigationView trong Preview để xem trước
        ProductListView()
    }
}
