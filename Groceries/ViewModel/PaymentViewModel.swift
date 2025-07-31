//
//  PaymentViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 18/3/25.

import SwiftUI
import WebKit

class PaymentViewModel: ObservableObject {
    static var shared: PaymentViewModel = PaymentViewModel()

    @Published var currentPayment: PaymentModel? // Có thể là nil nếu không có giao dịch.
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isPaymentCompleted = false
    @Published var showHomeButton = false // Thêm trạng thái để hiển thị nút Home

    func createPayment(orderId: Int, paymentMethod: String) {
        let params = ["orderId": orderId] as [String: Any]

        ServiceCall.post(parameter: params as NSDictionary, path: Globs.SV_CREATE_PAYMENT, withSuccess: { responseObj in
            if let response = responseObj as? NSDictionary {
                /*
                 {
                   "id": "pay_001",
                   "url": "https://paypal.com/pay",
                   "orderId": 123
                 }
                 */
                if let error = response["error"] as? String {
                    // { "error": "Invalid order ID" }
                    DispatchQueue.main.async {
                        self.errorMessage = error
                        self.showError = true
                        self.showHomeButton = true // Hiển thị nút Home khi có lỗi
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentPayment = PaymentModel(dict: response, orderId: orderId, paymentMethod: paymentMethod)
                        self.isPaymentCompleted = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server"
                    self.showError = true
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to create payment"
                self.showError = true
            }
        })
    }

    func confirmPayment(transactionId: String, orderId: Int, status: String) {
        // confirmPayment(transactionId: "trans_001", orderId: 123, status: "success")
        let params = [
            "transactionId": transactionId,
            "orderId": orderId,
            "status": status
        ] as [String: Any]
        
        /*
         Tạo một dictionary params chứa các thông tin cần gửi lên server:
         params = [
           "transactionId": "trans_001",
           "orderId": 123,
           "status": "success"
         ]
         */

        ServiceCall.post(parameter: params as NSDictionary, path: Globs.SV_CONFIRM_PAYMENT, withSuccess: { responseObj in
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    if response.contains("successful") {
                        self.currentPayment?.status = "COMPLETED"
                        self.isPaymentCompleted = true
                    } else {
                        self.currentPayment?.status = "FAILED"
                        self.errorMessage = response
                        self.showError = true
                    }
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to confirm payment"
                self.showError = true
            }
        })
    }

    func cancelPayment(token: String) {
        let pathWithParams = "\(Globs.SV_CANCEL_PAYMENT)?token=\(token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        // pathWithParams = "https://api.groceries.com/cancel-payment?token=pay_001"
        ServiceCall.get(path: pathWithParams, withSuccess: { responseObj in
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    self.currentPayment?.status = "FAILED"
                    self.errorMessage = response
                    self.showError = true
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to cancel payment"
                self.showError = true
            }
        })
    }

    func verifyPayment(paymentId: String, payerId: String, orderId: Int) {
        /*
         paymentId: String: ID thanh toán do cổng thanh toán (như PayPal) cung cấp (ví dụ: "PAY-12345").
         payerId: String: ID người thanh toán (PayPal cung cấp, ví dụ: "PAYER-67890").
         orderId: Int: ID đơn hàng liên quan (ví dụ: 123).
         */
        let pathWithParams = "\(Globs.SV_VERIFY_PAYMENT)?paymentId=\(paymentId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&PayerID=\(payerId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&orderId=\(String(orderId))"
        /*
         Với paymentId = "PAY-12345", payerId = "PAYER-67890", orderId = 123, URL là:
         pathWithParams = "https://api.groceries.com/verify-payment?paymentId=PAY-12345&PayerID=PAYER-67890&orderId=123"
         */
        ServiceCall.get(path: pathWithParams, withSuccess: { responseObj in
            if let response = responseObj as? String {
                DispatchQueue.main.async {
                    if response.contains("successful") {
                        self.currentPayment?.status = "COMPLETED"
                        self.isPaymentCompleted = true
                    } else {
                        self.currentPayment?.status = "FAILED"
                        self.errorMessage = response
                        self.showError = true
                    }
                }
            }
        }, failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Failed to verify payment"
                self.showError = true
            }
        })
    }

    func processCODPayment(orderId: Int) {
        self.currentPayment = PaymentModel(id: UUID().uuidString, orderId: orderId, paymentMethod: "COD", status: "COMPLETED")
        self.isPaymentCompleted = true
    }
    
    func handleNavigation(url: URL) {
        if url.absoluteString.contains("verify") {
            // Xử lý redirect từ PayPal hoặc MoMo
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                /* Với URL: https://api.groceries.com/verify?paymentId=PAY-12345&PayerID=PAYER-67890&orderId=123.
                 components.scheme = "https"
                 components.host = "api.groceries.com"
                 components.path = "/verify"
                 components.query = "paymentId=PAY-12345&PayerID=PAYER-67890&orderId=123"
                 ------------------------------------------
                 queryItems
                 [
                   URLQueryItem(name: "paymentId", value: "PAY-12345"),
                   URLQueryItem(name: "PayerID", value: "PAYER-67890"),
                   URLQueryItem(name: "orderId", value: "123")
                 ]
                 */
                let orderId = queryItems.first(where: { $0.name == "orderId" })?.value ?? ""
                let paymentId = queryItems.first(where: { $0.name == "paymentId" })?.value ?? ""
                let payerId = queryItems.first(where: { $0.name == "PayerID" })?.value ?? ""
                /* Mục đích: Lấy các tham số cần thiết để xác minh thanh toán (PayPal yêu cầu paymentId, payerId, orderId).
                 orderId = "123"
                 paymentId = "PAY-12345"
                 payerId = "PAYER-67890"
                */
                if currentPayment?.paymentMethod == "PAYPAL" {
                    // Xử lý PayPal
                    verifyPayment(paymentId: paymentId, payerId: payerId, orderId: Int(orderId) ?? 0)
                } else if currentPayment?.paymentMethod == "MOMO" {
                    // Xử lý MoMo (đã có ở trên)
                    let uniqueOrderId = queryItems.first(where: { $0.name == "uniqueOrderId" })?.value
                    let requestId = queryItems.first(where: { $0.name == "requestId" })?.value ?? ""
                    let amount = queryItems.first(where: { $0.name == "amount" })?.value ?? ""
                    let transId = queryItems.first(where: { $0.name == "transId" })?.value ?? ""
                    let resultCode = queryItems.first(where: { $0.name == "resultCode" })?.value ?? "0"
                    let signature = queryItems.first(where: { $0.name == "signature" })?.value ?? ""
                    let responseTime = queryItems.first(where: { $0.name == "responseTime" })?.value ?? "0"
                    let message = queryItems.first(where: { $0.name == "message" })?.value ?? ""
                    let payType = queryItems.first(where: { $0.name == "payType" })?.value ?? ""
                    let orderType = queryItems.first(where: { $0.name == "orderType" })?.value ?? ""
                    /*
                     uniqueOrderId = nil
                     requestId = ""
                     amount = "200000"
                     transId = "trans_001"
                     resultCode = "0"
                     signature = ""
                     responseTime = "0"
                     message = ""
                     payType = ""
                     orderType = ""
                     */
                    let pathWithParams = "\(Globs.SV_VERIFY_PAYMENT)?orderId=\(orderId)&uniqueOrderId=\(uniqueOrderId ?? "")&requestId=\(requestId)&amount=\(amount)&transId=\(transId)&resultCode=\(resultCode)&signature=\(signature)&responseTime=\(responseTime)&message=\(message)&payType=\(payType)&orderType=\(orderType)"
                    // let pathWithParams = "\(Globs.SV_VERIFY_PAYMENT)?orderId=\(orderId)&uniqueOrderId=\(uniqueOrderId ?? "")&requestId=\(requestId)&amount=\(amount)&transId=\(transId)&resultCode=\(resultCode)&signature=\(signature)&responseTime=\(responseTime)&message=\(message)&payType=\(payType)&orderType=\(orderType)"
                    ServiceCall.get(path: pathWithParams, withSuccess: { responseObj in
                        if let response = responseObj as? String {
                            DispatchQueue.main.async {
                                if response.contains("successful") {
                                    self.currentPayment?.status = "COMPLETED"
                                    self.isPaymentCompleted = true
                                    self.showHomeButton = true
                                } else {
                                    self.currentPayment?.status = "FAILED"
                                    self.errorMessage = response
                                    self.showError = true
                                    self.showHomeButton = true
                                }
                            }
                        }
                    }, failure: { error in
                        DispatchQueue.main.async {
                            self.errorMessage = error?.localizedDescription ?? "Không thể xác minh thanh toán MoMo"
                            self.showError = true
                            self.showHomeButton = true
                        }
                    })
                }
            } // let
        } else if url.absoluteString.contains("cancel") {
            // Xử lý khi người dùng hủy thanh toán
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let token = currentPayment?.id {
                cancelPayment(token: token)
            }
        }
    }

        // Thêm hàm để quay về Home
        func goToHome() {
            // Reset trạng thái và chuyển về Home
            self.currentPayment = nil
            self.isPaymentCompleted = false
            self.showError = false
            self.showHomeButton = false
            // Điều hướng về Home (có thể cần NavigationView hoặc TabView để xử lý)
        }
}
