//
//  ProductCell.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 9/12/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductCell: View {
    @State var pObj: ProductModel = ProductModel(dict: [:])
    @State var width: Double = 180.0 // Sử dụng @State với giá trị mặc định
    var didAddCart: (() -> ())?
    
    var body: some View {
        NavigationLink {
            ProductDetailView(productId: pObj.id)
        }
        label: {
            VStack {
                WebImage(url: URL(string: pObj.imageUrl ?? ""))
                    .resizable()
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: width - 30, height: 120) // Điều chỉnh kích thước ảnh
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .clipped()

                Spacer()
                
                Text(pObj.name)
                    .font(.customfont(.bold, fontSize: 16))
                    .foregroundColor(.primaryText)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Text(unitText())
                    .font(.customfont(.medium, fontSize: 14))
                    .foregroundColor(.secondaryText)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack {
                    Text("$\(pObj.offerPrice ?? pObj.price, specifier: "%.2f")")
                        .font(.customfont(.semibold, fontSize: 18))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
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
            }
            .padding(15)
            .frame(width: width, height: 230) // Sử dụng width từ @State
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.placeholder.opacity(0.5), lineWidth: 1)
            )
            .background(Color.white)
            .cornerRadius(20, corner: .allCorners)
        }
    }
    
    private func unitText() -> String {
        let hasUnitInfo = !pObj.unitValue.isEmpty && !pObj.unitName.isEmpty
        return hasUnitInfo ? "\(pObj.unitValue)\(pObj.unitName)/price" : ""
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(
            pObj: ProductModel(dict: [
                "offer_price": 2.49,
                "start_date": "2023-07-30T18:30:00.000Z",
                "end_date": "2023-08-29T18:30:00.000Z",
                "prod_id": 5,
                "cat_id": 1,
                "brand_id": 1,
                "type_id": 1,
                "name": "Organic Banana",
                "detail": "banana, fruit of the genus Musa, of the family Musaceae, one of the most important fruit crops of the world.",
                "unit_name": "pcs",
                "unit_value": "7",
                "nutrition_weight": "200g",
                "price": 2.9,
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
