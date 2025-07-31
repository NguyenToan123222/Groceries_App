//
//  OrderAcceptView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.

import SwiftUI

struct OrderAcceptView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    let orderId: Int?
    @State private var isTrackingOrder = false

    var body: some View {
        ZStack {
            Image("bottom_bg")
                .resizable()
                .scaledToFill()
                .frame(width: .screenWidth, height: .screenHeight)
            
            VStack {
                Spacer()
                Image("order_accpeted")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .screenWidth * 0.7)
                    .padding(.bottom, 32)
                
                Text("Your order has been \n accepted")
                    .multilineTextAlignment(.center)
                    .font(.customfont(.semibold, fontSize: 28))
                    .foregroundColor(.primaryText)
                    .padding(.bottom, 12)
                
                Text("Your items has been placed and is on\nit’s way to being processed")
                    .multilineTextAlignment(.center)
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 12)
                
                Spacer()
                Spacer()
                
                RoundButton(tittle: "Track Order") {
                    if orderId != nil {
                        isTrackingOrder = true
                        MyOrdersViewModel.shared.refreshOrders() // Làm mới danh sách đơn hàng
                    }
                }
                
                Button {
                    mode.wrappedValue.dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("NavigateToHome"), object: nil)
                } label: {
                    Text("Back to Home")
                        .font(.customfont(.semibold, fontSize: 18))
                        .foregroundColor(.primaryApp)
                        .padding(.vertical, 15)
                }
                .padding(.bottom, .bottomInsets + 15)
            } // VStack
            .padding(.horizontal, 20)

            NavigationLink(destination: MyOrdersView(), isActive: $isTrackingOrder) {
                EmptyView()
            }
        } // ZStack
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct OrderAcceptView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderAcceptView(orderId: 1)
        }
    }
}
