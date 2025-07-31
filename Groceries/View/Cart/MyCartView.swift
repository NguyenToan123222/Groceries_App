// MyCartView.swift
// Groceries
//
// Created by Nguyễn Toàn on 16/3/25.
//

import SwiftUI

struct MyCartView: View {
    
    @StateObject var cartVM = CartViewModel.shared
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var animateBackground = false
    @State private var animateHeader = false
    @State private var animateItems = false
    @State private var animateCheckoutButton = false
    @State private var isCheckoutActive = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 360 : 0))
                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animateBackground)

            if cartVM.listArr.isEmpty {
                Text("Your Cart is Empty")
                    .font(.customfont(.bold, fontSize: 20))
                    .offset(y: animateItems ? 0 : 50)
                    .opacity(animateItems ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: animateItems)
            }
            /*
             cartVM.listArr = [CartItem(id: "P101", productName: "Apple", price: 2.50, quantity: 2), CartItem(id: "P102", productName: "Banana", price: 1.50, quantity: 1)]
             */
            ScrollView {
                LazyVStack {
                    ForEach(cartVM.listArr, id: \.id) { item in
                        CartItemRow(cartVM: cartVM, productId: item.id ?? 0)
                            .offset(x: animateItems ? 0 : -50)
                            .opacity(animateItems ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(Double(cartVM.listArr.firstIndex(of: item) ?? 0) * 0.1), value: animateItems)
                    }// For
                    .padding(.vertical, 8)
                } // Lazy
                .padding(.top, .topInsets + 30)
                .padding(20)
                .padding(.bottom, .bottomInsets + 80)
            } // Scroll

            VStack {
                HStack {
                    Spacer()
                    Text("My Cart")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)
                        .offset(y: animateHeader ? 0 : -50)
                        .opacity(animateHeader ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: animateHeader)
                    Spacer()
                }
                .padding(20)
                .padding(.top, 23)
                .background(Color.white)

                Spacer()

                if !cartVM.listArr.isEmpty {
                    Button {
                        isCheckoutActive = true
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
                    .scaleEffect(animateCheckoutButton ? 1.0 : 0.8)
                    .opacity(animateCheckoutButton ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheckoutButton)
                }
            } // VStack

            NavigationLink(destination: CheckoutView(userId: mainVM.userObj.id).environmentObject(mainVM), isActive: $isCheckoutActive) {
                EmptyView()
            }
        } // Zstack
        .onAppear {
            cartVM.serviceCallList()
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
                .environmentObject(MainViewModel.shared)
        }
    }
}

/*
 {
   "data": {
     "userId": 3,
     "cartId": "251ca17e754f4473a9bdf97c85509a4a",
     "items": [
       {
         "id": 101,
         "productId": 5,
         "productName": "Apple",
         "quantity": 2,
         "imageUrl": "https://example.com/assets/images/apple.jpg",
         "price": 2.00,
         "totalPrice": 4.00,
         "discountPercentage": 20.0,
         "originalPrice": 2.50,
         "startDate": "2025-07-01T00:00:00Z",
         "endDate": "2025-07-15T23:59:59Z"
       },
       {
         "id": 102,
         "productId": 1,
         "productName": "Fresh Milk",
         "quantity": 1,
         "imageUrl": "https://example.com/assets/images/milk.jpg",
         "price": 3.00,
         "totalPrice": 3.00,
         "discountPercentage": null,
         "originalPrice": null,
         "startDate": null,
         "endDate": null
       },
       {
         "id": 103,
         "productId": 2,
         "productName": "Banana",
         "quantity": 3,
         "imageUrl": "https://example.com/assets/images/banana.jpg",
         "price": 1.20,
         "totalPrice": 3.60,
         "discountPercentage": 10.0,
         "originalPrice": 1.50,
         "startDate": "2025-07-10T00:00:00Z",
         "endDate": "2025-07-20T23:59:59Z"
       }
     ],
     "count": 3,
     "total": 10.60
   }
 }
 */
