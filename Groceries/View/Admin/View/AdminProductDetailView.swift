//
//  AdminProductDetailView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 14/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct AdminProductDetailView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var detailVM: ProductDetailViewModel
    @ObservedObject var adminVM: AdminViewModel // Thêm AdminViewModel để truy cập danh sách nutritions
    @State private var isImageLoaded = false
    @State private var isContentVisible = false

    // MARK: - Initialization
    init(productId: Int, adminVM: AdminViewModel) {
        _detailVM = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
        self.adminVM = adminVM
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
            topBarView
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

            // Hiển thị giá và badge giảm giá
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Nếu có giảm giá, hiển thị badge và giá gốc
                    if let offerPrice = detailVM.pObj.offerPrice, offerPrice < detailVM.pObj.price {
                        if let discount = detailVM.pObj.discountPercentage {
                            Text("-\(Int(discount))% OFF")
                                .font(.customfont(.bold, fontSize: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        
                        Text("$\(detailVM.pObj.price, specifier: "%.2f")")
                            .font(.customfont(.medium, fontSize: 20))
                            .foregroundColor(.red)
                            .strikethrough(true, color: .red)
                    }
                    
                    // Giá hiện tại (offerPrice nếu có, nếu không thì price)
                    Text("$\(detailVM.pObj.offerPrice ?? detailVM.pObj.price, specifier: "%.2f")")
                        .font(.customfont(.bold, fontSize: 28))
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .opacity(isContentVisible ? 1.0 : 0.0)
            .offset(y: isContentVisible ? 0 : 20)
            .animation(.easeInOut(duration: 0.5).delay(0.4), value: isContentVisible)

            Divider()
                .padding(.horizontal, 20)

            descriptionView

            Divider()
                .padding(.horizontal, 20)

            nutritionView

            Divider()
                .padding(.horizontal, 20)

            reviewView
        }
        .padding(.bottom, 20)
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
                        if let nutrition = adminVM.nutritions.first(where: { $0.id == nObj.nutritionId }) {
                            HStack {
                                Text(nutrition.name) // Hiển thị tên thay vì ID
                                    .font(.customfont(.semibold, fontSize: 15))
                                    .foregroundColor(.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(formatNutritionValue(nObj.value))\(nutrition.unit)") // Sử dụng hàm để định dạng giá trị
                                    .font(.customfont(.semibold, fontSize: 15))
                                    .foregroundColor(.primaryText)
                            }
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 30)
                .opacity(isContentVisible ? 1.0 : 0.0)
                .offset(y: isContentVisible ? 0 : 20)
                .animation(.easeInOut(duration: 0.5).delay(0.6), value: isContentVisible)
            }
        }

        // Hàm định dạng giá trị dinh dưỡng
        private func formatNutritionValue(_ value: Double) -> String {
            if floor(value) == value {
                return String(Int(value)) // Nếu là số nguyên, bỏ phần thập phân
            } else {
                return String(format: "%.2f", value) // Nếu có phần thập phân, giữ 2 chữ số
            }
        }
    // MARK: - Review View
    private var reviewView: some View {
        VStack {
            HStack {
                Text("Review")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Star rating view
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        starView(for: index)
                    }
                }
                
                // Next button
                nextButton
            }
            .padding(.horizontal, 20)
        }
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.7), value: isContentVisible)
    }

    private func starView(for index: Int) -> some View {
        let isFilled = index <= Int(detailVM.pObj.avgRating ?? 0)
        return Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(isFilled ? .orange : .gray)
            .frame(width: 15, height: 15)
            .scaleEffect(isFilled ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.1),
                      value: detailVM.pObj.avgRating)
    }

    private var nextButton: some View {
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
        AdminProductDetailView(productId: 1, adminVM: AdminViewModel())
    }
}
