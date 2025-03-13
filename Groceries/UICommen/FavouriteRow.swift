//
//  FavouriteRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteRow: View {
    @State var fObj: ProductModel = ProductModel(dict: [:])
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                WebImage(url: URL(string: fObj.image ))
                    .resizable()
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 4){
                    
                    Text(fObj.name)
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(fObj.unitValue)\(fObj.unitName), price")
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.secondaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                }
                
                Text("$\(fObj.offerPrice ?? fObj.price, specifier: "%.2f" )")
                    .font(.customfont(.semibold, fontSize: 18))
                    .foregroundColor(.primaryText)
                    
                Image("next_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                
                
            }
            Divider()
        }
    }
}

struct FavouriteRow_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteRow(fObj: ProductModel(dict: [
            "prod_id": 1,
            "name": "Organic Apple",
            "detail": "Fresh organic apples, rich in vitamins.",
            "unit_name": "kg",
            "unit_value": "4",
            "nutrition_weight": "250g",
            "price": 3.99,
            "offer_price": 2.9,
            "image": "https://t4.ftcdn.net/jpg/04/96/45/49/360_F_496454926_VsM8D2yyMDFzAm8kGCNFd7vkKpt7drrK.jpg",
            "cat_name": "Fresh Fruits",
            "type_name": "Fruit",
            "is_fav": 1
        ]))
    }
}
