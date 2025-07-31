//
//  BestSellingListView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 4/11/25.
//

import SwiftUI

struct BestSellingListView: View {
    @StateObject var homeVM = HomeViewModel.shared
    
    // Tính width dựa trên screenWidth
    private var calculatedWidth: Double {
        let padding: Double = 40 // Padding hai bên (20 + 20)
        let spacing: Double = 15 // Khoảng cách giữa 2 cột
        return (CGFloat.screenWidth - padding - spacing) / 2
        /*
         Giả sử screenWidth = 390 (iPhone 14):
         padding = 40 (20 trái + 20 phải).
         spacing = 15 (khoảng cách giữa hai cột).
         calculatedWidth = (390 - 40 - 15) / 2 = 335 / 2 = 167.5 điểm.
         */
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                if homeVM.bestSellingList.isEmpty {
                    Text("No best-selling products available")
                        .font(.customfont(.medium, fontSize: 16))
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                            // : Tạo 2 cột có chiều rộng linh hoạt, chia đều không gian có sẵn. spacing: 15: Khoảng cách 15 điểm giữa các cột.
                        ],
                        spacing: 15 // giữa các hàng.
                    ) {
                        ForEach(homeVM.bestSellingList, id: \.id) { pObj in
                            ProductCell(pObj: pObj, didAddCart: {
                                CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                    if isDone {
                                        homeVM.successMessage = msg
                                        homeVM.showSuccess = true
                                    }
                                    else {
                                        homeVM.errorMessage = msg
                                        homeVM.showError = true
                                    }
                                }
                            })
                        
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            } // Scroll
        } // Zstack
        .navigationTitle("Best Selling Products")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $homeVM.showError, content: {
            Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
        })
        .alert(isPresented: $homeVM.showSuccess, content: {
            Alert(title: Text(Globs.AppName), message: Text(homeVM.successMessage), dismissButton: .default(Text("OK")))
        })
    }
}

#Preview {
    NavigationView {
        BestSellingListView()
    }
}
