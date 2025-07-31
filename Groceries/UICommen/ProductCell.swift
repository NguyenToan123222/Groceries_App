//
//  ProductCell.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 9/12/24.
import SwiftUI
import SDWebImageSwiftUI

struct ProductCell: View {
    @State var pObj: ProductModel = ProductModel(dict: [:])
    @State var width: Double = 180.0
    var didAddCart: (() -> ())?

    var body: some View {
        NavigationLink {
            ProductDetailView(productId: pObj.id)
        } label: {
            ZStack(alignment: .topLeading) {
                VStack {
                    // Hình ảnh sản phẩm
                    WebImage(url: URL(string: pObj.imageUrl ?? ""))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5)) // tạo hiệu ứng mờ dần khi hình ảnh xuất hiện.
                        .scaledToFill()
                        .frame(width: width - 30, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipped()

                    Spacer()

                    // Tên sản phẩm
                    Text(pObj.name)
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    // Đơn vị
                    Text(unitText())
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.secondaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    // Hiển thị giá
                    HStack {
                        VStack(alignment: .leading) {
                            // Nếu có giảm giá, hiển thị giá gốc (màu đỏ, gạch ngang)
                            if let offerPrice = pObj.offerPrice, offerPrice < pObj.price {
                                Text("$\(pObj.price, specifier: "%.2f")")
                                    .font(.customfont(.medium, fontSize: 14))
                                    .foregroundColor(.red)
                                    .strikethrough(true, color: .red) // Gạch ngang
                            }

                            // Giá hiện tại (offerPrice nếu có, nếu không thì price)
                            Text("$\(pObj.offerPrice ?? pObj.price, specifier: "%.2f")")
                                .font(.customfont(.semibold, fontSize: 18))
                                .foregroundColor(.primaryText)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        // Nút thêm vào giỏ hàng
                        Button {
                            didAddCart?()
                        } label: {
                            Image("add")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.primaryApp)
                        .cornerRadius(15)
                    }
                } // Vstack
                .padding(15)
                .frame(width: width, height: 230)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.placeholder.opacity(0.5), lineWidth: 1)
                )
                .background(Color.white)
                .cornerRadius(20, corner: .allCorners)

                // Badge giảm giá (nếu có)
                if let discount = pObj.discountPercentage, pObj.offerPrice != nil, pObj.offerPrice! < pObj.price {
                    Text("-\(Int(discount))%")
                        .font(.customfont(.bold, fontSize: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(8)
                        .offset(x: 10, y: 10) // Đặt ở góc trên bên trái
                }
            } // H
        }
    }

    private func unitText() -> String {
        let hasUnitInfo = !pObj.unitValue.isEmpty && !pObj.unitName.isEmpty
        return hasUnitInfo ? "\(pObj.unitValue)\(pObj.unitName)/price" : ""
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        ProductCell(
            pObj: ProductModel(dict: [
                "id" : 5,
                "offer_price": 2.49,
                "start_date": "2023-07-30T18:30:00.000Z",
                "end_date": "2023-08-29T18:30:00.000Z",
                "prod_id": 5,
                "cat_id": 1,
                "brand_id": 1,
                "type_id": 1,
                "name": "Organic Banana",
                "detail": "banana, fruit of the genus Musa, of the family Musaceae, one of the most important fruit crops of the world.",
                "unitName": "pcs",
                "unitValue": "7",
                "nutrition_weight": "200g",
                "price": 2.9,
                "offer": ["discountPercentage": 15.0, "offerPrice": 2.49], // Thêm dữ liệu offer để kiểm tra
                "imageUrl": "https://plus.unsplash.com/premium_photo-1661322640130-f6a1e2c36653?fm=jpg&q=60&w=3000&ixlib=rb-4.0",
                "cat_name": "Fresh Fruits & Vegetable",
                "type_name": "Pulses",
                "is_fav": 1
            ])
        ) {
            // Mô phỏng didAddCart
        }
    }
}
}
