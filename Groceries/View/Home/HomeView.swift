//
//  HomeView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 8/12/24.
//
import SwiftUI

struct HomeView: View {
    
    @StateObject var homeVM = HomeViewModel.shared
    @StateObject var explorVM = ExploreViewModel.shared // Thêm ExploreViewModel để lấy danh mục
    
    @State private var animateBackground = false
    @State private var animateLogo = false
    @State private var animateComponents = false
    
    @State private var isRefreshing = false
    @FocusState private var isFocused: Bool
    
    @Environment(\.presentationMode) var presentationMode

    // Cấu hình 2 cột cho LazyVGrid
    var columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.dismissKeyboardGlobally()
    }

    var body: some View {
        NavigationView {
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
                        }// H
                        .offset(x: animateComponents ? 0 : 50)
                        .opacity(animateComponents ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateComponents)
                        
                        SearchTextField(placeholder: "Search Store", txt: $homeVM.txtSearch)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .offset(y: animateComponents ? 0 : 20)
                            .opacity(animateComponents ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateComponents)
                            .onChange(of: homeVM.txtSearch) { newValue in
                                homeVM.searchProducts(name: newValue)
                            }
                    } // V
                    .padding(.top, .topInsets)
                    
                    if !homeVM.txtSearch.isEmpty && !homeVM.filteredProducts.isEmpty { // homeVM.txtSearch = "Apple" | homeVM.filteredProducts = [{"id": 1, "name": "Apple", "price": 2.0}]
                        // Hiển thị kết quả tìm kiếm theo dạng lưới 2 cột
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(homeVM.filteredProducts, id: \.id) { pObj in
                                    NavigationLink(destination: ProductDetailView(productId: pObj.id)) {
                                        ProductCell(pObj: pObj, didAddCart: {
                                            CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                                self.homeVM.errorMessage = msg
                                                self.homeVM.showError = true
                                            }
                                        })
                                        .offset(x: animateComponents ? 0 : -50)
                                        .opacity(animateComponents ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5).delay(Double(homeVM.filteredProducts.firstIndex(of: pObj) ?? 0) * 0.1), value: animateComponents)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        .padding(.bottom, 35)
                    } else if !homeVM.txtSearch.isEmpty && homeVM.filteredProducts.isEmpty { // homeVM.txtSearch = "Apple" | homeVM.filteredProducts = []
                        // Hiển thị thông báo không tìm thấy sản phẩm
                        Text("No products found")
                            .font(.customfont(.medium, fontSize: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                    } else {  // ô tìm kiếm rỗng (homeVM.txtSearch.isEmpty), bất kể homeVM.filteredProducts có rỗng hay không
                        // Hiển thị danh sách sản phẩm gốc
                        Image("banner_top")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 115)
                            .padding(.horizontal, 20)
                            .offset(y: animateComponents ? 0 : 20)
                            .opacity(animateComponents ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateComponents)
                        
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
                        
                        
                        // Thêm mục Categories
                        NavigationLink(destination: CategoriesView()) {
                            SectionTitleAll(
                                title: "Categories",
                                titleAll: "See All",
                                sectionType: .custom
                            )
                            .padding(.horizontal, 20)
                            .offset(x: animateComponents ? 0 : -50)
                            .opacity(animateComponents ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(1.1), value: animateComponents)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                if explorVM.listArr.isEmpty {
                                    Text("No categories available")
                                        .font(.customfont(.medium, fontSize: 16))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 20)
                                } else {
                                    ForEach(explorVM.listArr.indices, id: \.self) { index in
                                        let cObj = explorVM.listArr[index]
                                        NavigationLink(destination: ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: cObj))) {
                                            ExploreCategoryCell(cObj: cObj)
                                                .frame(width: 130, height: 130) // Điều chỉnh kích thước cho phù hợp
                                                .offset(x: animateComponents ? 0 : -50)
                                                .opacity(animateComponents ? 1 : 0)
                                                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1 + 1.2), value: animateComponents)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                        .padding(.bottom, 35)
                    } //else
                } // Scroll
            } // zstack
    
            .alert(isPresented: $homeVM.showError, content: {
                Alert(title: Text(Globs.AppName), message: Text(homeVM.errorMessage), dismissButton: .default(Text("OK")))
            })
            .padding(.bottom, .bottomInsets + 25)
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToHome"))) { _ in
                presentationMode.wrappedValue.dismiss()
            }
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
