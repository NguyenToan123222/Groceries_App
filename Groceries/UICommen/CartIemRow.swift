//
//  CartItemRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

// Component hiển thị từng sản phẩm trong giỏ hàng
struct CartItemRow: View {
    @ObservedObject var cartVM: CartViewModel
    let productId: Int // Chỉ truyền productId để lấy dữ liệu từ listArr
    @State private var isUpdating = false // Trạng thái để disable nút khi đang cập nhật

    var body: some View {
        // Lấy item trực tiếp từ listArr dựa trên productId
        if let item = cartVM.listArr.first(where: { $0.productId == productId }) {
            HStack {
                // Hình ảnh sản phẩm
                AsyncImage(url: URL(string: item.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }

                // Thông tin sản phẩm
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productName)
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.primaryText)
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.customfont(.regular, fontSize: 14))
                        .foregroundColor(.secondaryText)
                }
                .padding(.leading, 10)

                Spacer()

                // Nút tăng/giảm số lượng và xóa
                VStack {
                    HStack(spacing: 8) {
                        // Nút giảm số lượng
                        Button(action: {
                            if item.quantity > 1 && !isUpdating {
                                isUpdating = true
                                cartVM.serviceCallUpdateQty(cObj: item, newQty: item.quantity - 1) { success, message in
                                    isUpdating = false
                                    if !success {
                                        print("Error reducing quantity: \(message)")
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(item.quantity > 1 ? .primaryApp : .gray)
                                .font(.system(size: 20))
                        }
                        .disabled(isUpdating || item.quantity <= 1)

                        // Hiển thị quantity trực tiếp từ item
                        Text("\(item.quantity)")
                            .font(.customfont(.semibold, fontSize: 16))
                            .foregroundColor(.primaryText)

                        // Nút tăng số lượng
                        Button(action: {
                            if !isUpdating {
                                isUpdating = true
                                cartVM.serviceCallUpdateQty(cObj: item, newQty: item.quantity + 1) { success, message in
                                    isUpdating = false
                                    if !success {
                                        print("Error increasing quantity: \(message)")
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.primaryApp)
                                .font(.system(size: 20))
                        }
                        .disabled(isUpdating)
                    }

                    // Nút xóa sản phẩm
                    Button(action: {
                        if !isUpdating {
                            isUpdating = true
                            cartVM.serviceCallRemove(cObj: item) { success, message in
                                isUpdating = false
                                if !success {
                                    print("Error removing item: \(message)")
                                }
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                    .disabled(isUpdating)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        } else {
            // Hiển thị placeholder nếu không tìm thấy item (trường hợp hiếm)
            Text("Item not found")
                .foregroundColor(.red)
                .padding()
        }
    }
}

struct CartItemRow_Previews: PreviewProvider {
    static var previews: some View {
        CartItemRow(cartVM: CartViewModel.shared, productId: 5)
            .padding(.horizontal, 20)
    }
}
