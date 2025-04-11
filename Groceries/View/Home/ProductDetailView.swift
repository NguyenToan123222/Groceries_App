//
//  ProductDetailView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var detailVM: ProductDetailViewModel
    @StateObject var favVM = FavouriteViewModel.shared // ViewModel for favorites
    
    @State private var isImageLoaded = false
    @State private var isContentVisible = false
    @State private var isFavorite = false
    @State private var showAlert = false // For showing add/remove favorite alerts
    @State private var alertMessage = "" // Message for the alert
    
    // MARK: - Initialization
    init(productId: Int) {
        _detailVM = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
            topBarView
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(Globs.AppName),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $detailVM.showError) {
            Alert(
                title: Text(Globs.AppName),
                message: Text(detailVM.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isContentVisible = true
            }
            // Làm mới danh sách yêu thích trước khi kiểm tra trạng thái
                favVM.serviceCallDetail()
            // Check initial favorite status
            isFavorite = favVM.listArr.contains { $0.id == detailVM.pObj.id }
        }
        .onChange(of: favVM.listArr) { newList in
            // Update favorite status when the list changes
            isFavorite = newList.contains { $0.id == detailVM.pObj.id }
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Color.white.edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                productImageView
                productInfoView
            }
        }
    }
    
    // MARK: - Product Image View
    private var productImageView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(hex: "F2F2F2"))
                .frame(width: .screenWidth, height: .screenWidth * 0.8)
                .cornerRadius(35, corner: [.bottomLeft, .bottomRight])
            
            WebImage(url: URL(string: detailVM.pObj.imageUrl ?? "https://img.freepik.com/free-vector/illustration-gallery-icon_53876-27002.jpg"))
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)
                .scaleEffect(isImageLoaded ? 1.0 : 0.8)
                .opacity(isImageLoaded ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        isImageLoaded = true
                    }
                }
        }
        .frame(width: .screenWidth, height: .screenWidth * 0.8)
    }
    
    // MARK: - Product Info View
    private var productInfoView: some View {
        VStack(spacing: 20) {
            Text(detailVM.pObj.name)
                .font(.customfont(.bold, fontSize: 24))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .opacity(isContentVisible ? 1.0 : 0.0)
                .offset(y: isContentVisible ? 0 : 20)
                .animation(.easeInOut(duration: 0.5).delay(0.2), value: isContentVisible)
            
            Text("\(detailVM.pObj.unitValue) \(detailVM.pObj.unitName), Price")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .opacity(isContentVisible ? 1.0 : 0.0)
                .offset(y: isContentVisible ? 0 : 20)
                .animation(.easeInOut(duration: 0.5).delay(0.3), value: isContentVisible)
            
            quantityAndPriceView
            
            Divider()
                .padding(.horizontal, 20)
            
            descriptionView
            
            Divider()
                .padding(.horizontal, 20)
            
            nutritionView
            
            Divider()
                .padding(.horizontal, 20)
            
            reviewView
            
            addToCartButtonView
        }
    }
    
    // MARK: - Quantity and Price View
    private var quantityAndPriceView: some View {
        HStack {
            HStack(spacing: 15) {
                Button(action: {
                    withAnimation {
                        detailVM.addSubQty(isAdd: false)
                    }
                }) {
                    Image("subtack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Text("\(detailVM.qty)")
                    .font(.customfont(.bold, fontSize: 24))
                    .foregroundColor(.primaryText)
                    .frame(width: 45, height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.placeholder.opacity(0.5), lineWidth: 1)
                    )
                    .scaleEffect(detailVM.qty > 1 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: detailVM.qty)
                
                Button(action: {
                    withAnimation {
                        detailVM.addSubQty(isAdd: true)
                    }
                }) {
                    Image("add_green")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            Text("$\((detailVM.pObj.offerPrice ?? detailVM.pObj.price) * Double(detailVM.qty), specifier: "%.2f")")
                .font(.customfont(.bold, fontSize: 28))
                .foregroundColor(.primaryText)
                .scaleEffect(detailVM.qty > 1 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: detailVM.qty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.4), value: isContentVisible)
    }
    
    // MARK: - Description View
    private var descriptionView: some View {
        VStack {
            Text("Description")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            Text(detailVM.pObj.description ?? "No description available")
                .font(.customfont(.medium, fontSize: 13))
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .opacity(isContentVisible ? 1.0 : 0.0)
                .offset(y: isContentVisible ? 0 : 20)
                .animation(.easeInOut(duration: 0.5).delay(0.5), value: isContentVisible)
        }
    }
    
    // MARK: - Nutrition View
    private var nutritionView: some View {
        VStack {
            Text("Nutritions")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 10) {
                ForEach(detailVM.pObj.nutritionValues) { nObj in
                    HStack {
                        Text("Nutrition ID: \(nObj.nutritionId)")
                            .font(.customfont(.semibold, fontSize: 15))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(nObj.value, specifier: "%.2f")")
                            .font(.customfont(.semibold, fontSize: 15))
                            .foregroundColor(.primaryText)
                    }
                    Divider()
                }
            }
            .padding(.horizontal, 30)
            .opacity(isContentVisible ? 1.0 : 0.0)
            .offset(y: isContentVisible ? 0 : 20)
            .animation(.easeInOut(duration: 0.5).delay(0.6), value: isContentVisible)
        }
    }
    
    // MARK: - Review View
    private var reviewView: some View {
        HStack {
            Text("Review")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(index <= (detailVM.pObj.avgRating ?? 0) ? .orange : .gray)
                        .frame(width: 15, height: 15)
                        .scaleEffect(index <= (detailVM.pObj.avgRating ?? 0) ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.1), value: detailVM.pObj.avgRating)
                }
            }
            
            Button(action: {
                // Navigate to review view (if implemented)
            }) {
                Image("next_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .padding(15)
                    .foregroundColor(.primaryText)
            }
        }
        .padding(.horizontal, 20)
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.7), value: isContentVisible)
    }
    
    // MARK: - Add to Cart Button View
    private var addToCartButtonView: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                CartViewModel.shared.serviceCallAddToCart(prodId: detailVM.pObj.id, qty: detailVM.qty) { isDone, msg in
                    detailVM.qty = 1 // Reset quantity after adding to cart
                    detailVM.errorMessage = msg
                    detailVM.showError = true
                }
            }
        }) {
            Text("Add To Basket")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(20)
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.8), value: isContentVisible)
    }
    
    // MARK: - Top Bar View
    private var topBarView: some View {
        VStack {
            HStack {
                Button(action: {
                    mode.wrappedValue.dismiss()
                }) {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        if isFavorite {
                            // Remove from favorites
                            favVM.removeFavorite(productId: detailVM.pObj.id) { success, message in
                                if success {
                                    isFavorite = false
                                    alertMessage = "Removed from favorites."
                                    showAlert = true
                                } else {
                                    alertMessage = message
                                    showAlert = true
                                }
                            }
                        } else {
                            // Add to favorites
                            favVM.addFavorite(productId: detailVM.pObj.id) { success, message in
                                if success {
                                    isFavorite = true
                                    alertMessage = "Added to favorites."
                                    showAlert = true
                                } else {
                                    // Kiểm tra thủ công xem sản phẩm đã được thêm chưa
                                    isFavorite = favVM.listArr.contains { $0.id == detailVM.pObj.id }
                                    if isFavorite {
                                        alertMessage = "Added to favorites."
                                        showAlert = true
                                    } else {
                                        alertMessage = message
                                        showAlert = true
                                    }
                                }
                            }
                        }
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                
                Button(action: {
                    // Handle sharing (if implemented)
                }) {
                    Image("share")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(productId: 1)
    }
}
