//
//  t.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/7/25.
//

import SwiftUI

struct t: View {
    var body: some View {
        ZStack {
            // Nền đỏ phủ toàn màn hình
            Color.red.edgesIgnoringSafeArea(.all)
            
            // Nội dung chính (mainContentView) nằm giữa
            VStack {
                Text("Product Image")
                    .frame(height: 200)
                Text("Product Info")
                    .frame(height: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Đảm bảo nội dung nằm giữa
            
            // Thanh trên cùng (topBarView) cố định ở trên
            HStack {
                Text("Back")
                Spacer()
                Text("Favorite")
            }
            .padding(.top, 50)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top) // Giới hạn chiều cao và giữ trên cùng
            
            // Nút Add To Basket cố định ở dưới cùng
            Text("Add To Basket")
                .padding()
                .background(Color.green)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                .position(x: 150, y: 480) // Định vị thủ công ở dưới cùng (500 - 20)
        }
        .frame(width: 300, height: 500)
    }
}

#Preview {
    t()
}


// hâhhahahahahah



// vvvv 31/7/2025
