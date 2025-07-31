//
//  PaymentMethodsView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 18/3/25.


import SwiftUI
import WebKit

struct PaymentMethodsView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var payVM = PaymentViewModel.shared
    @State private var showWebView = false
    @State private var selectedPaymentMethod: String?
    var orderId: Int // Truyền orderId từ màn hình trước (ví dụ: Checkout)

    var body: some View {
        ZStack {
            VStack {
                // Header
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }

                    Spacer()

                    Text("Select Payment Method")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)

                    Spacer()
                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)

                // Payment Method Selection
                ScrollView {
                    LazyVStack(spacing: 15) {
                        // PayPal
                        PaymentMethodRow(method: "PayPal", image: "paypal_icon") {
                            selectedPaymentMethod = "PAYPAL"
                            payVM.createPayment(orderId: orderId, paymentMethod: "PAYPAL")
                        }

                        // MoMo
                        PaymentMethodRow(method: "MoMo", image: "momo_icon") {
                            selectedPaymentMethod = "MOMO"
                            payVM.createPayment(orderId: orderId, paymentMethod: "MOMO")
                        }

                        // COD
                        PaymentMethodRow(method: "Cash on Delivery (COD)", image: "cod_icon") {
                            selectedPaymentMethod = "COD"
                            payVM.processCODPayment(orderId: orderId)
                        }
                    }
                    .padding(20)
                    .padding(.top, 20)
                    .padding(.bottom, .bottomInsets + 60)
                }
            } // VStack

            // WebView cho PayPal/MoMo
            /*
             showWebView = true (được đặt trong .onChange(of: payVM.currentPayment) khi chọn PayPal/MoMo).
             payVM.currentPayment = Payment(id: "123", paymentMethod: "PAYPAL", paymentUrl: "https://paypal.com/pay/123", orderId: 1).
             paymentUrl = "https://paypal.com/pay/123".
             url = URL(string: "https://paypal.com/pay/123").
             */
            if showWebView, let paymentUrl = payVM.currentPayment?.paymentUrl, let url = URL(string: paymentUrl) {
                WebView(url: url, onNavigation: { url in
                    /*
                     Với url = URL(string: "https://paypal.com/pay/123"), WebView tải trang thanh toán PayPal.
                     Khi người dùng hoàn thành thanh toán, PayPal chuyển hướng đến một URL như "https://paypal.com/payment-success?paymentId=123&PayerID=abc&orderId=1". Closure onNavigation sẽ nhận URL này để xử lý.
                     */
                    // Xử lý URL trả về từ PayPal/MoMo
                    if url.absoluteString.contains("payment-success") {
                        if let payment = payVM.currentPayment { // payVM.currentPayment = Payment(id: "123", paymentMethod: "PAYPAL", paymentUrl: "https://paypal.com/pay/123", orderId: 1)
                            if payment.paymentMethod == "PAYPAL" {
                                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                                /* trích xuất URL
                                 url = URL(string: "https://paypal.com/payment-success?paymentId=123&PayerID=abc&orderId=1"), components chứa:
                                 host: "paypal.com".
                                 path: "/payment-success".
                                 queryItems: [URLQueryItem(name: "paymentId", value: "123"), URLQueryItem(name: "PayerID", value: "abc"), URLQueryItem(name: "orderId", value: "1")].
                                 */
                                let paymentId = components?.queryItems?.first(where: { $0.name == "paymentId" })?.value // paymentId = "123".
                                let payerId = components?.queryItems?.first(where: { $0.name == "PayerID" })?.value // payerId = "abc"
                                let orderId = components?.queryItems?.first(where: { $0.name == "orderId" })?.value // orderId = "1"

                                if let paymentId = paymentId, let payerId = payerId, let orderId = orderId {
                                    payVM.verifyPayment(paymentId: paymentId, payerId: payerId, orderId: payment.orderId) // được gọi để gửi yêu cầu xác nhận đến server PayPal, đảm bảo thanh toán được hoàn tất.
                                }
                            } else if payment.paymentMethod == "MOMO" {
                                payVM.confirmPayment(transactionId: payment.id, orderId: payment.orderId, status: "COMPLETED")
                            }
                        }
                        showWebView = false
                    } else if url.absoluteString.contains("payment-callback") || url.absoluteString.contains("cancel") { // thanh toán bị hủy hoặc gặp lỗi.
                        if let payment = payVM.currentPayment {
                            payVM.cancelPayment(token: payment.id)
                        }
                        showWebView = false
                    }
                })
                .ignoresSafeArea()
            }
        } // Zstack
        .alert(isPresented: $payVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(payVM.errorMessage))
        }
        .onChange(of: payVM.currentPayment) { newPayment in
            if let payment = newPayment, payment.paymentMethod != "COD", payment.paymentUrl != nil {
                showWebView = true
            }
        }
        .onChange(of: payVM.isPaymentCompleted) { completed in
            if completed {
                mode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

struct PaymentMethodRow: View {
    let method: String
    let image: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(method)
                .font(.customfont(.bold, fontSize: 18))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.15), radius: 2)
        .onTapGesture {
            action()
        }
    }
}

// WebView để hiển thị trang thanh toán PayPal/MoMo
struct WebView: UIViewRepresentable {
    let url: URL
    let onNavigation: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                parent.onNavigation(url)
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.onNavigation(url)
            }
            decisionHandler(.allow)
        }
    }
}

struct PaymentMethodsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PaymentMethodsView(orderId: 1)
        }
    }
}

/*
 {
   "id": "3C6798364W1234567",
   "status": "COMPLETED",
   "amount": {
     "currency_code": "USD",
     "value": "100.00"
   },
   "final_capture": true,
   "create_time": "2025-07-12T10:00:00Z",
   "update_time": "2025-07-12T10:00:00Z",
   "links": [
     {
       "href": "https://api.paypal.com/v2/payments/captures/3C6798364W1234567",
       "rel": "self",
       "method": "GET"
     }
   ]
 }
 
 
 {
   "name": "INSTRUMENT_DECLINED",
   "message": "The requested action could not be performed, semantically incorrect, or failed business validation.",
   "details": [
     {
       "issue": "INSTRUMENT_DECLINED",
       "description": "The funding instrument presented was either declined by the processor or bank, or it can't be used for this payment."
     }
   ],
   "links": [
     {
       "href": "https://developer.paypal.com/docs/api/payments/v2/#error",
       "rel": "information_link"
     }
   ]
 }
 
 
 {
   "partnerCode": "MOMO",
   "orderId": "123456",
   "requestId": "abc123",
   "amount": 100000,
   "transId": 123456789,
   "resultCode": 0,
   "message": "Thành công",
   "payUrl": "https://test-payment.momo.vn/v2/gateway/123456",
   "responseTime": 1628777777777
 }
 
 
 {
   "partnerCode": "MOMO",
   "orderId": "123456",
   "requestId": "abc123",
   "amount": 100000,
   "resultCode": 1001,
   "message": "Thông tin thanh toán không hợp lệ",
   "responseTime": 1628777777777
 }
 */
