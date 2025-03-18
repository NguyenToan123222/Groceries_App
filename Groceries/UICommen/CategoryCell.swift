//
//  CategoryCell.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 10/12/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct CategoryCell: View {
    @State var tObj: TypeModel = TypeModel(dict: [:])
    @State var color: Color = Color.yellow
    var didAddCart: ( ()-> ())?
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: tObj.image ))
                .resizable()
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: 70, height: 70)
            
            Text ("Pulses")
                .font(.customfont(.bold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            
        }
        .padding(15)
        .frame(width: 250, height: 100)
        .background(color.opacity(0.3))
        .cornerRadius(16)
    }
}

#Preview {
    CategoryCell(tObj: TypeModel(dict: ["type_id": 1,
                                        "type_name": "Fruits",
                                        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
                                        "color": "FF5733"]))
}
