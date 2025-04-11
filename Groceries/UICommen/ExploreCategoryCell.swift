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
            WebImage(url: URL(string: cObj.image))
                .resizable()
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: 100, height: 70) // Giảm kích thước hình ảnh để giống giao diện trong hình
            
            Spacer()
            
            Text(cObj.name)
                .font(.customfont(.bold, fontSize: 14)) // Giảm kích thước chữ
                .foregroundColor(.primaryText)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .lineLimit(2) // Cho phép xuống dòng nếu tên dài (như "Fresh Fruits & Vegetable")
            
            Spacer()
        }
        .padding(10) // Giảm padding để ô nhỏ gọn hơn
        .background(cObj.color.opacity(0.2)) // Giảm độ mờ của màu nền
        .cornerRadius(10) // Giảm góc bo tròn
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(cObj.color.opacity(0.5), lineWidth: 1) // Làm viền mờ hơn
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
