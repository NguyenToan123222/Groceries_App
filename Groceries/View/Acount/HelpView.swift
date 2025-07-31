//
//  HelpView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/3/25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Tiêu đề
            Text("Help & Support")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Danh sách FAQ
            VStack(alignment: .leading, spacing: 15) {
                Text("Frequently Asked Questions")
                    .font(.headline)
                
                DisclosureGroup("How do I track my order?") {
                    Text("You can track your order by going to the 'Orders' section in your account and selecting the order you want to track.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.black)
                
                DisclosureGroup("What if my delivery is late?") {
                    Text("If your delivery is delayed, please contact our support team via the button below.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.black)
                
                DisclosureGroup("How do I cancel an order?") {
                    Text("To cancel an order, go to 'Orders', select the order, and choose 'Cancel' if the option is available.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal)
            
            // Nút liên hệ hỗ trợ
            Button(action: {
                // Giả lập hành động gửi email hỗ trợ
                print("Contact support pressed")
            }) {
                Text("Contact Support")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Help") // Tiêu đề thanh điều hướng
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    NavigationView {
        HelpView()
    }
}
