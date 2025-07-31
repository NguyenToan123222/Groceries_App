//
//  PaymentView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 23/4/25.
//

import SwiftUI

struct PaymentView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var paymentVM = PaymentViewModel.shared
    @State private var showWebView = true

    var body: some View {
        ZStack {
            if showWebView, let paymentUrl = paymentVM.currentPayment?.paymentUrl, let url = URL(string: paymentUrl) {
                PaymentWebView(url: url, onNavigation: { url in
                    paymentVM.handleNavigation(url: url)
                    self.showWebView = false
                }, onError: { error in
                    paymentVM.errorMessage = error
                    paymentVM.showError = true
                    paymentVM.showHomeButton = true
                    self.showWebView = false
                })
                .ignoresSafeArea()
            } else {
                VStack {
                    if paymentVM.showError {
                        Text(paymentVM.errorMessage)
                            .font(.customfont(.regular, fontSize: 16))
                            .foregroundColor(.red)
                            .padding()
                    }

                    if paymentVM.isPaymentCompleted {
                        Text("Thanh toán thành công! 🎉")
                            .font(.customfont(.bold, fontSize: 20))
                            .foregroundColor(.green)
                            .padding()
                    }

                    if paymentVM.showHomeButton {
                        Button(action: {
                            paymentVM.goToHome()
                            mode.wrappedValue.dismiss() // Quay về màn hình trước (có thể là Home)
                        }) {
                            Text("Quay về Trang chủ")
                                .font(.customfont(.bold, fontSize: 16))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    PaymentView()
}
