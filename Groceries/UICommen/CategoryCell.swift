//
//  CategoryCell.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 10/12/24.
//

import SwiftUI

struct CategoryCell: View {
    @State var tObj: TypeModel = TypeModel(dict: [:])
    @State var color: Color = Color.yellow
    var didAddCart: ( ()-> ())?
    
    var body: some View {
        HStack {
            Image (tObj.image)
                .resizable()
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
                                        "image": "ginger",
                                        "color": "FF5733"]))
}
