//
//  HomeView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 8/12/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var homeVM = HomeViewModel.shared
    
    @State private var animateBackground = false
    @State private var animateLogo = false
    @State private var animateComponents = false
    @State private var isRefreshing = false
    
    @FocusState private var isFocused: Bool
        
    func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.dismissKeyboardGlobally()
    }

    var body: some View {
        NavigationView { // Bao bọc bằng NavigationView để hỗ trợ điều hướng
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
                
                ScrollView {
                    PullToRefreshView(isRefreshing: $isRefreshing) {
                        homeVM.serviceCallList()
                        homeVM.serviceCallBestSelling()
                        homeVM.serviceCallExclusiveOffers()
                        isRefreshing = false
                    }
                    
                    VStack {
                        Image("color_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .rotationEffect(.degrees(animateLogo ? 360 : 0))
                            .scaleEffect(animateLogo ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                        
                        HStack {
                            Image("location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            
                            Text("SaiGon International University")
                                .font(.customfont(.semibold, fontSize: 18))
                                .foregroundColor(.darkGray)
                        }
                        .offset(x: animateComponents ? 0 : 50)
                        .opacity(animateComponents ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateComponents)
                        
                        SearchTextField(placeholder: "Search Store", txt: $homeVM.txtSearch)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .offset(y: animateComponents ? 0 : 20)
                            .opacity(animateComponents ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateComponents)
                    }
                    .padding(.top, .topInsets)
                    
                    Image("banner_top")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 115)
                        .padding(.horizontal, 20)
                        .offset(y: animateComponents ? 0 : 20)
                        .opacity(animateComponents ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateComponents)
                    
                    // Section Best Selling Products
                    SectionTitleAll(
                        title: "Best Selling Products",
                        titleAll: "See All",
                        sectionType: .bestSelling
                    )
                    .padding(.horizontal, 20)
                    .offset(x: animateComponents ? 0 : -50)
                    .opacity(animateComponents ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.5), value: animateComponents)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            if homeVM.bestSellingList.isEmpty {
                                Text("No best-selling products available")
                                    .font(.customfont(.medium, fontSize: 16))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(homeVM.bestSellingList, id: \.id) { pObj in
                                    ProductCell(pObj: pObj, didAddCart: {
                                        CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                            self.homeVM.errorMessage = msg
                                            self.homeVM.showError = true
                                        }
                                    })
                                    .offset(x: animateComponents ? 0 : -50)
                                    .opacity(animateComponents ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateComponents)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    .padding(.bottom, 35)
                    
                    // Section Exclusive Offers
                    SectionTitleAll(
                        title: "Exclusive Offers",
                        titleAll: "See All",
                        sectionType: .exclusiveOffers
                    )
                    .padding(.horizontal, 20)
                    .offset(x: animateComponents ? 0 : -50)
                    .opacity(animateComponents ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.7), value: animateComponents)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            if homeVM.exclusiveOfferList.isEmpty {
                                Text("No exclusive offers available")
                                    .font(.customfont(.medium, fontSize: 16))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(homeVM.exclusiveOfferList, id: \.id) { pObj in
                                    ProductCell(pObj: pObj, didAddCart: {
                                        CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                            self.homeVM.errorMessage = msg
                                            self.homeVM.showError = true
                                        }
                                    })
                                    .offset(x: animateComponents ? 0 : -50)
                                    .opacity(animateComponents ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(0.8), value: animateComponents)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    .padding(.bottom, 35)
                    
                    // Section All Products
                    SectionTitleAll(
                        title: "All Products",
                        titleAll: "See All",
                        sectionType: .allProducts
                    )
                    .padding(.horizontal, 20)
                    .offset(x: animateComponents ? 0 : -50)
                    .opacity(animateComponents ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.9), value: animateComponents)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach(homeVM.productList, id: \.id) { pObj in
                                ProductCell(pObj: pObj, didAddCart: {
                                    CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                        self.homeVM.errorMessage = msg
                                        self.homeVM.showError = true
                                    }
                                })
                                .offset(x: animateComponents ? 0 : -50)
                                .opacity(animateComponents ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(1.0), value: animateComponents)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    .padding(.bottom, 35)
                }
            }
            .alert(isPresented: $homeVM.showError, content: {
                Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
            })
            .padding(.bottom, .bottomInsets + 20)
            .ignoresSafeArea()
            .onAppear {
                animateLogo = true
                animateComponents = true
                homeVM.serviceCallList()
                homeVM.serviceCallBestSelling()
                homeVM.serviceCallExclusiveOffers()
            }
            .onDisappear {
                dismissKeyboard()
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct PullToRefreshView: View {
    @Binding var isRefreshing: Bool
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 0 {
                Spacer()
                    .onAppear {
                        if !isRefreshing {
                            isRefreshing = true
                            action()
                        }
                    }
            }
        }
        .frame(height: 0)
    }
}

#Preview {
    HomeView()
}
