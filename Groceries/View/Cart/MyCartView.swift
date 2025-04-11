//
//  MyCartView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.
//

import SwiftUI

struct MyCartView: View {
    @StateObject var cartVM = CartViewModel.shared
    @State private var animateBackground = false
    @State private var animateHeader = false
    @State private var animateItems = false
    @State private var animateCheckoutButton = false

    var body: some View {
        ZStack {
            // Gradient background động
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animateBackground)

            // Thông báo giỏ hàng trống
            if cartVM.listArr.isEmpty {
                Text("Your Cart is Empty")
                    .font(.customfont(.bold, fontSize: 20))
                    .offset(y: animateItems ? 0 : 50) // Trượt từ dưới lên
                    .opacity(animateItems ? 1 : 0) // Hiệu ứng mờ dần
                    .animation(.easeInOut(duration: 0.5), value: animateItems)
            }

            // Danh sách sản phẩm
            ScrollView {
                LazyVStack {
                    ForEach(cartVM.listArr, id: \.productId) { item in
                        // Truyền productId thay vì cObj
                        CartItemRow(cartVM: cartVM, productId: item.productId ?? 0)
                            .offset(x: animateItems ? 0 : -50)
                            .opacity(animateItems ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(Double(cartVM.listArr.firstIndex(of: item) ?? 0) * 0.1), value: animateItems)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.top, .topInsets + 30)
                .padding(20)
            }

            // Tiêu đề và nút Check Out
            VStack {
                HStack {
                    Spacer()
                    Text("My Cart")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)
                        .offset(y: animateHeader ? 0 : -50) // Trượt từ trên xuống
                        .opacity(animateHeader ? 1 : 0) // Hiệu ứng mờ dần
                        .animation(.easeInOut(duration: 0.5), value: animateHeader)
                    Spacer()
                }
                .padding(20)
                .padding(.top, 23)
                .background(Color.white)

                Spacer()

                if !cartVM.listArr.isEmpty {
                    Button {
                        // Xử lý checkout nếu cần
                    } label: {
                        Text("Check Out $\(cartVM.total)")
                            .font(.customfont(.semibold, fontSize: 18))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.primaryApp)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, .bottomInsets + 63)
                    .scaleEffect(animateCheckoutButton ? 1.0 : 0.8) // Phóng to khi xuất hiện
                    .opacity(animateCheckoutButton ? 1.0 : 0.0) // Hiệu ứng mờ dần
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheckoutButton)
                }
            }
        }
        .onAppear {
            cartVM.serviceCallList() // Làm mới danh sách giỏ hàng khi màn hình xuất hiện
            animateBackground = true
            animateHeader = true
            animateItems = true
            animateCheckoutButton = true
        }
        .alert(isPresented: $cartVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(cartVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .ignoresSafeArea()
    }
}

struct MyCartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyCartView()
        }
    }
}
