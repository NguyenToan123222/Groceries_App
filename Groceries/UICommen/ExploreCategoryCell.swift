//
//  ExploreCategoryCell.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExploreCategoryCell: View {
    @State var cObj: ExploreCategoryModel
    
    var body: some View {
        VStack {
            // Sử dụng hình ảnh từ Assets nếu có, nếu không thì dùng URL
            if let assetImageName = cObj.assetImageName {
                Image(assetImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 100)
                    .clipped()
            } else {
                WebImage(url: URL(string: cObj.image))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 100, height: 70)
            }
            
            Spacer()
            
            Text(cObj.name)
                .font(.customfont(.bold, fontSize: 14))
                .foregroundColor(.primaryText)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(10)
        .background(Color(hex: cObj.color).opacity(0.2)) // Sửa lỗi: Chỉ gọi Color(hex:) một lần
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: cObj.color).opacity(0.5), lineWidth: 1) // Sửa lỗi: Chỉ gọi Color(hex:) một lần
        )
    }
}

struct ExploreCategoryCell_Previews: PreviewProvider {
    static var previews: some View {
        ExploreCategoryCell(cObj: ExploreCategoryModel(dict: [
            "cat_id": 1,
            "cat_name": "Fresh Fruits & Vegetable",
            "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
            "color": "53B175"
        ]))
        .padding(20)
    }
}
