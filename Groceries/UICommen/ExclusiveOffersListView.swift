//
//  ExclusiveOffersListView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 4/11/25.
//

import SwiftUI

struct ExclusiveOffersListView: View {
    @ObservedObject var homeVM = HomeViewModel.shared // Sửa từ @StateObject thành @ObservedObject
    
    private var calculatedWidth: Double {
        let padding: Double = 40
        let spacing: Double = 15
        return (CGFloat.screenWidth - padding - spacing) / 2
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                if homeVM.exclusiveOfferList.isEmpty {
                    Text("No exclusive offers available")
                        .font(.customfont(.medium, fontSize: 16))
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ],
                        spacing: 15
                    ) {
                        ForEach(homeVM.exclusiveOfferList, id: \.id) { pObj in
                            ProductCell(pObj: pObj, didAddCart: {
                                CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                    homeVM.errorMessage = msg
                                    homeVM.showError = true
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                
                Spacer()
                    .frame(minHeight: CGFloat.screenHeight - 200)
            }
        }
        .navigationTitle("Exclusive Offers")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $homeVM.showError, content: {
            Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
        })
        .onAppear {
            homeVM.serviceCallExclusiveOffers() // Gọi lại API để đảm bảo dữ liệu được cập nhật khi view xuất hiện
        }
    }
}

#Preview {
    NavigationView {
        ExclusiveOffersListView()
    }
}

/* {
 "categories": [
   {"id": 1, "name": "Fruits"},
   {"id": 2, "name": "Vegetables"}
 ],
 "products": [
   {"id": 1, "name": "Organic Apple", "category": "Fruits", "price": 2.99, "imageUrl": "https://example.com/apple.jpg"},
   {"id": 2, "name": "Banana", "category": "Fruits", "price": 1.5, "imageUrl": "https://example.com/banana.jpg"},
   {"id": 3, "name": "Carrot", "category": "Vegetables", "price": 1.99, "imageUrl": "https://example.com/carrot.jpg"},
   {"id": 4, "name": "Orange", "price": 2.49, "imageUrl": "https://example.com/orange.jpg"} // Không danh mục
 ]
}*/
