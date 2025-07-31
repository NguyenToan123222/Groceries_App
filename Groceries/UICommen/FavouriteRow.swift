//
//  FavouriteRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteRow: View {
    @State var fObj: ProductModel
    @StateObject var cartVM = CartViewModel.shared
    @StateObject var favoriteVM = FavouriteViewModel.shared
    var onDelete: (Int) -> Void
    var onAddToCart: (Int) -> Void
/* - Vì FavouriteRow chỉ chịu trách nhiệm hiển thị giao diện và gửi yêu cầu (gọi onDelete hoặc onAddToCart khi nhấn nút). Logic xử lý thực tế (xóa khỏi danh sách yêu thích, thêm vào giỏ hàng) được thực hiện trong FavouriteView hoặc ViewModel (favVM, CartViewModel.shared), thường qua API.
  - Thay vì trả về giá trị ngay (như true nếu xóa thành công), closure sử dụng callback (hàm gọi lại) để thông báo kết quả sau khi API hoàn tất. Điều này giúp tách biệt trách nhiệm: FavouriteRow gửi yêu cầu, FavouriteView xử lý và phản hồi qua alert.*/
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                // Hình ảnh sản phẩm
                WebImage(url: URL(string: fObj.imageUrl ?? "https://img.freepik.com/free-vector/illustration-gallery-icon_53876-27002.jpg"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Tên và đơn vị sản phẩm
                VStack(spacing: 4) {
                    Text(fObj.name)
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    Text(unitDisplayText)
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.secondaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                
                // Hiển thị giá
                if fObj.isDiscountValid, let offerPrice = fObj.offerPrice, offerPrice < fObj.price {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.2f", offerPrice))
                            .font(.customfont(.semibold, fontSize: 18))
                            .foregroundColor(.red)
                        Text(String(format: "$%.2f", fObj.price))
                            .font(.customfont(.regular, fontSize: 12))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                } else {
                    Text(String(format: "$%.2f", fObj.price))
                        .font(.customfont(.semibold, fontSize: 18))
                        .foregroundColor(.primaryText)
                }
                
                // Nút thêm vào giỏ hàng
                Button(action: {
                    onAddToCart(fObj.id)
                }) {
                    Image(systemName: "cart.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Nút xóa
                Button(action: {
                    onDelete(fObj.id)
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Điều hướng đến chi tiết sản phẩm
                NavigationLink(destination: ProductDetailView(productId: fObj.id)) {
                    Image("next_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
        }
    }
    
    // Hiển thị đơn vị
    private var unitDisplayText: String {
        let components = [fObj.unitValue, fObj.unitName].filter { !$0.isEmpty }
        return components.isEmpty ? "" : components.joined(separator: " ") + ", price"
    }
}

struct FavouriteRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavouriteRow(
                fObj: ProductModel(dict: [
                    "id": 1,
                    "name": "Organic Apple",
                    "price": 3.99,
                    "stock": 100,
                    "unitName": "kg",
                    "unitValue": "1",
                    "imageUrl": "https://t4.ftcdn.net/jpg/04/96/45/49/360_F_496454926_VsM8D2yyMDFzAm8kGCNFd7vkKpt7drrK.jpg",
                    "category": ["name": "Fresh Fruits"],
                    "brand": ["name": "Fruit"],
                    "avgRating": 4.5,
                    "exclusiveOfferProducts": [
                        ["offerPrice": 2.99, "discountPercentage": 25.0]
                    ]
                ]),
                onDelete: { productId in
                    print("Deleted product with ID: \(productId)")
                },
                onAddToCart: { productId in
                    print("Added product with ID: \(productId) to cart")
                }
            )
        }
    }
}
