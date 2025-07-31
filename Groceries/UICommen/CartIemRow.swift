//
//  CartItemRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartItemRow: View {
    @ObservedObject var cartVM: CartViewModel
    let productId: Int // Đây là ID của cart item (trùng với id trong CartItemModel)
    @State private var isUpdating = false

    var body: some View {
        if let item = cartVM.listArr.first(where: { $0.id == productId }) {
            HStack {
                AsyncImage(url: URL(string: item.imageUrl)) { image in // khi tải thành công
                    image //Hình ảnh đã tải xong
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView() // Loading
                        .frame(width: 60, height: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productName)
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.primaryText)
                    if item.isDiscountValid && item.price < (item.originalPrice ?? item.price) {
                        HStack {
                            Text("$\(String(format: "%.2f", item.price))")
                                .font(.customfont(.regular, fontSize: 14))
                                .foregroundColor(.red)
                            Text("$\(String(format: "%.2f", item.originalPrice ?? item.price))")
                                .font(.customfont(.regular, fontSize: 12))
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                    } else {
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.customfont(.regular, fontSize: 14))
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.leading, 10)

                Spacer()

                VStack {
                    HStack(spacing: 8) {
                        Button(action: {
                            if item.quantity > 1 && !isUpdating { // !false = true
                                isUpdating = true
                                cartVM.serviceCallUpdateQty(cObj: item, newQty: item.quantity - 1) { success, message in
                                    isUpdating = false // done
                                    if !success { // false
                                        print("Error reducing quantity: \(message)")
                                    }
                                }
                            } // if 1
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(item.quantity > 1 ? .primaryApp : .gray)
                                .font(.system(size: 20))
                        }
                        .disabled(isUpdating || item.quantity <= 1)

                        Text("\(item.quantity)")
                            .font(.customfont(.semibold, fontSize: 16))
                            .foregroundColor(.primaryText)

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
                    } // H

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
                } // V
            } // Hstack
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        } else {
            Text("Item not found")
                .foregroundColor(.red)
                .padding()
        }
    } // body
}

struct CartItemRow_Previews: PreviewProvider {
    static var previews: some View {
        CartItemRow(cartVM: CartViewModel.shared, productId: 3)
            .padding(.horizontal, 20)
    }
}
