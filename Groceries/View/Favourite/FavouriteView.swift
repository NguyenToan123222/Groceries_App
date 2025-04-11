//
//  FavouriteView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteView: View {
    @StateObject var favVM = FavouriteViewModel.shared
    
    @State private var animateBackground = false
    @State private var animateHeader = false
    @State private var animateItems = false
    @State private var animateButton = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                VStack {
                    headerView
                    favoritesListView
                    addToCartButtonView
                }
            }
            .onAppear {
                favVM.serviceCallDetail()
                animateHeader = true
                animateItems = true
                animateButton = true
            }
            .ignoresSafeArea()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
        .hueRotation(.degrees(animateBackground ? 360 : 0))
        .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animateBackground)
        .onAppear {
            animateBackground = true
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("Favorites")
                .font(.customfont(.bold, fontSize: 20))
                .frame(height: 46)
                .offset(y: animateHeader ? 0 : -50)
                .opacity(animateHeader ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: animateHeader)
            Spacer()
        }
        .padding(.top, .topInsets)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.2), radius: 2)
    }
    
    private var favoritesListView: some View {
        ScrollView {
            LazyVStack {
                if favVM.listArr.isEmpty {
                    Text("No favorites yet")
                        .font(.customfont(.medium, fontSize: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ForEach(favVM.listArr) { fObj in
                        FavouriteRow(
                            fObj: fObj,
                            onDelete: { productId in
                                favVM.removeFavorite(productId: productId) { success, message in
                                    if success {
                                        alertMessage = "Removed '\(fObj.name)' from favorites."
                                        showAlert = true
                                    } else {
                                        alertMessage = message
                                        showAlert = true
                                    }
                                }
                            },
                            onAddToCart: { productId in
                                CartViewModel.shared.serviceCallAddToCart(prodId: productId, qty: 1) { success, message in
                                    if success {
                                        alertMessage = "Added '\(fObj.name)' to cart."
                                        showAlert = true
                                    } else {
                                        alertMessage = message
                                        showAlert = true
                                    }
                                }
                            }
                        )
                        .offset(x: animateItems ? 0 : -50)
                        .opacity(animateItems ? 1 : 0)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .delay(Double(favVM.listArr.firstIndex(of: fObj) ?? 0) * 0.1),
                            value: animateItems
                        )
                    }
                }
            }
            .padding(20)
            .padding(.top, 46)
            .padding(.bottom, .bottomInsets + 60)
        }
    }
    
    private var addToCartButtonView: some View {
        RoundButton(tittle: "Add All To Cart") {
            CartViewModel.shared.addMultipleToCart(products: favVM.listArr) { success, message in
                if success {
                    alertMessage = "All items added to cart."
                    showAlert = true
                } else {
                    alertMessage = message
                    showAlert = true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, .bottomInsets + 80)
        .scaleEffect(animateButton ? 1.0 : 0.8)
        .opacity(animateButton ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateButton)
    }
}

struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProducts = [
            ProductModel(dict: [
                "id": 1,
                "name": "Organic Apple",
                "detail": "Fresh organic apples, rich in vitamins.",
                "unit_name": "kg",
                "unit_value": "1",
                "nutrition_weight": "250g",
                "price": 3.99,
                "offer_price": 2.99,
                "imageUrl": "https://t4.ftcdn.net/jpg/04/96/45/49/360_F_496454926_VsM8D2yyMDFzAm8kGCNFd7vkKpt7drrK.jpg",
                "category": "Fresh Fruits",
                "brand": "Fruit",
                "is_fav": 1
            ]),
            ProductModel(dict: [
                "id": 2,
                "name": "Carrot",
                "detail": "Crunchy and nutritious carrots.",
                "unit_name": "kg",
                "unit_value": "2",
                "nutrition_weight": "300g",
                "price": 2.49,
                "offer_price": 1.99,
                "imageUrl": "https://media.istockphoto.com/id/1388403435/photo/fresh-carrots-isolated-on-white-background.jpg?s=612x612&w=0&k=20&c=XmrTb_nASc7d-4zVKUz0leeTT4fibDzWi_GpIun0Tlc=",
                "category": "Vegetables",
                "brand": "Root Vegetable",
                "is_fav": 0
            ]),
            ProductModel(dict: [
                "id": 3,
                "name": "Fresh Milk",
                "detail": "Organic whole milk, rich in calcium.",
                "unit_name": "L",
                "unit_value": "1",
                "nutrition_weight": "1L",
                "price": 4.99,
                "offer_price": 3.99,
                "imageUrl": "https://img.freepik.com/free-vector/realistic-vector-icon-illustration-dairy-farm-fresh-milk-splash-with-milk-jug-bottle-isola_134830-2399.jpg?semt=ais_hybrid",
                "category": "Dairy",
                "brand": "Milk",
                "is_fav": 1
            ]),
            ProductModel(dict: [
                "id": 4,
                "name": "Whole Wheat Bread",
                "detail": "Healthy whole wheat bread.",
                "unit_name": "pcs",
                "unit_value": "1",
                "nutrition_weight": "500g",
                "price": 2.99,
                "offer_price": 2.49,
                "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgkeYnkvGnkSzX16RireD06ZhVdjT1EZ6FUg&s",
                "category": "Bakery",
                "brand": "Bread",
                "is_fav": 0
            ])
        ]
        
        let favVM = FavouriteViewModel.shared
        favVM.listArr = sampleProducts
        
        return FavouriteView()
            .environmentObject(favVM)
    }
}
