//
//  AboutView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/3/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Logo hoặc biểu tượng ứng dụng
            Image(systemName: "cart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding(.top, 40)
            
            // Tên ứng dụng
            Text("Groceries")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Thông tin phiên bản
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Mô tả
            Text("Groceries is your one-stop app for ordering fresh groceries delivered to your door. Built with love by our team.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Thông tin nhà phát triển
            VStack(alignment: .leading, spacing: 10) {
                Text("Developed by:")
                    .font(.headline)
                Text("Nguyễn Toàn")
                    .font(.body)
                    .foregroundColor(.gray)
                Text("Contact: support@groceriesapp.com")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Bản quyền
            Text("© 2025 Groceries. All rights reserved.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .navigationTitle("About")
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
