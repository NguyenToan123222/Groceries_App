//  ProductDetailView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @StateObject var detailVM: ProductDetailViewModel
    @StateObject var favVM = FavouriteViewModel.shared
    @StateObject var reviewVM = ReviewViewModel.shared

    @State private var isImageLoaded = false
    @State private var isContentVisible = false
    @State private var isFavorite = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var canReview = false
    @State private var showWriteReview = false
    @State private var newRating: Float = 0.0
    @State private var newComment: String = ""

    init(productId: Int) {
        _detailVM = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            mainContentView
            topBarView
            addToCartButtonView
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
        // Bo alert cho reviewVM.showError
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(
                rating: $newRating,
                comment: $newComment,  // new
                onSubmit: {
                    reviewVM.addReview(productId: detailVM.pObj.id, rating: newRating, comment: newComment.isEmpty ? nil : newComment) { success, message in
                        if success {
                            reviewVM.fetchReviews(productId: detailVM.pObj.id) {}
                            canReview = false
                        }
                        alertMessage = message
                        showAlert = true
                        showWriteReview = false
                    }
                },
                onCancel: {
                    showWriteReview = false
                }
            )
        } // shet
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isContentVisible = true // Kích hoạt hiệu ứng hiển thị nội dung (tên, giá, đánh giá, v.v.).
            }
            favVM.serviceCallDetail {// Tải danh sách yêu thích để kiểm tra xem sản phẩm hiện tại có được yêu thích không
                isFavorite = favVM.listArr.contains { $0.id == detailVM.pObj.id }
                // Cách hoạt động: Kiểm tra xem ID của sản phẩm hiện tại (detailVM.pObj.id) có trong danh sách yêu thích (favVM.listArr) không, gán kết quả vào @State var isFavorite.
            }
            reviewVM.canUserReview(productId: detailVM.pObj.id) { can in
                self.canReview = can
                // Kiểm tra xem người dùng có quyền viết đánh giá cho sản phẩm không.
            }
        }
        .onChange(of: detailVM.pObj.id) { newId in
            if newId != 0 {
                // Reset trạng thái của reviewVM trước khi fetch dữ liệu mới
                reviewVM.showError = false
                reviewVM.errorMessage = ""
                reviewVM.listArr = []
                
                reviewVM.fetchReviews(productId: newId) {} // tải đánh giá cho sp
                reviewVM.canUserReview(productId: newId) { can in // review
                    self.canReview = can
                }
            }
        }
        .onChange(of: favVM.listArr) { newList in // newList = [Orange, Banana, Carrot].
            // Theo dõi favVM.listArr, chạy closure khi danh sách thay đổi, nhận newList là danh sách mới.
            isFavorite = newList.contains { $0.id == detailVM.pObj.id }
            //$0.id == detailVM.pObj.id so sánh ID của từng sản phẩm trong newList với ID của sản phẩm hiện tại (detailVM.pObj.id).
        }
    } // body

    private var backgroundView: some View {
        Color.white.edgesIgnoringSafeArea(.all)
    }

    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                productImageView
                productInfoView
            }
        }
    }

    private var productImageView: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(Color(hex: "F2F2F2"))
                .frame(width: .screenWidth, height: .screenWidth * 0.8)
                .cornerRadius(35, corner: [.bottomLeft, .bottomRight])

            WebImage(url: URL(string: detailVM.pObj.imageUrl ?? "https://img.freepik.com/free-vector/illustration-gallery-icon_53876-27002.jpg"))
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: .screenWidth, height: .screenWidth * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
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

            if canReview {
                Button(action: {
                    newRating = 0.0
                    newComment = ""
                    showWriteReview = true
                }) {
                    Text("Write Review")
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }

            
        } // Vstack
        
    }

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
            } // H2

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
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
                }
                Text("$\(detailVM.pObj.price * Double(detailVM.qty), specifier: "%.2f")")
                    .font(.customfont(.medium, fontSize: 20))
                    .foregroundColor(.red)
                    .strikethrough(true, color: .red)
                
                Text("$\((detailVM.pObj.offerPrice ?? detailVM.pObj.price) * Double(detailVM.qty), specifier: "%.2f")")// ưu tiên offerPrice, nếu không thì price
                    .font(.customfont(.bold, fontSize: 28))
                    .foregroundColor(.primaryText)
                    .scaleEffect(detailVM.qty > 1 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: detailVM.qty)
            } // V
        } // Hstack
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.4), value: isContentVisible)
    }

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
        } // V
    }

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

    private var reviewView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Review")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                let filledStars = Int(detailVM.pObj.avgRating ?? 0)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundColor(index <= filledStars ? .orange : .gray)
                            .scaleEffect(index <= filledStars ? 1.2 : 1.0)
                    }
                }

                Button(action: {
                    // Co the dan den man hinh chi tiet danh gia neu can
                }) {
                    Image("next_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .padding(15)
                        .foregroundColor(.primaryText)
                }
            } // Vstack

            if reviewVM.showError {
                Text("Failed to load reviews.")
                    .font(.customfont(.medium, fontSize: 14))
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 20)
            } else if reviewVM.listArr.isEmpty {
                Text("No reviews yet.")
                    .font(.customfont(.medium, fontSize: 14))
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 20)
            } else {
                ForEach(reviewVM.listArr) { review in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(index <= Int(review.rating) ? .orange : .gray)
                            }
                            Spacer()
                            Text(review.createdAt.displayDate(format: "yyyy-MM-dd"))
                                .font(.customfont(.regular, fontSize: 12))
                                .foregroundColor(.secondaryText)
                        }
                        if let comment = review.comment, !comment.isEmpty { // review.comment không nil và không rỗng
                            Text(comment)
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.primaryText)
                        }
                    } // V
                    .padding(.horizontal, 20)
                    Divider()
                        .padding(.horizontal, 20)
                } // for
            } // else
        }
        .padding(.horizontal, 20)
        .opacity(isContentVisible ? 1.0 : 0.0)
        .offset(y: isContentVisible ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.7), value: isContentVisible)
    } /*
       listArr = [ReviewModel(id: 101, rating: 4.0, comment: "Great taste!", createdAt: ...), ReviewModel(id: 102, rating: 5.0, ...)]
       */

    private var addToCartButtonView: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                CartViewModel.shared.serviceCallAddToCart(prodId: detailVM.pObj.id, qty: detailVM.qty) { isDone, msg in
                    detailVM.qty = 1
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
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }

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
                            favVM.addFavorite(productId: detailVM.pObj.id) { success, message in
                                if success {
                                    isFavorite = true
                                    alertMessage = "Added to favorites."
                                    showAlert = true
                                } else {
                                    isFavorite = favVM.listArr.contains { $0.id == detailVM.pObj.id }
                                    alertMessage = isFavorite ? "Added to favorites." : message
                                    showAlert = true
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
/*
 Nhấn nút Favorite:
     isFavorite = false → Chạy addFavorite(5).
     API trả về: {"success": true, "message": "Added successfully"}.
     isFavorite = true, icon đổi thành "heart.fill" đỏ, alert: "Added to favorites."
 Nhấn lại:
     isFavorite = true → Chạy removeFavorite(5).
     API trả về: {"success": true, "message": "Removed successfully"}.
     isFavorite = false, icon đổi thành "heart" xám, alert: "Removed from favorites."
 
 */
                Button(action: {
                    // Xu ly chia se (neu duoc trien khai)
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
            } // HStack
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)

            Spacer()
        }
    }
} // struct


#Preview {
    NavigationView {
        ProductDetailView(productId: 1)
    }
}
/*
 [
   {
     "id": 101,
     "userId": 1,
     "productId": 5,
     "rating": 4.0,
     "comment": "Great taste!",
     "createdAt": "2025-07-14T10:00:00Z"
   },
   {
     "id": 102,
     "userId": 2,
     "productId": 5,
     "rating": 5.0,
     "comment": "Very fresh and juicy!",
     "createdAt": "2025-07-13T15:30:00Z"
   }
 ]
 
 */
