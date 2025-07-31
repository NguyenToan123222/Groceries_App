//
//  PaymentWebView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 23/4/25.
//


import SwiftUI
import WebKit

struct PaymentWebView: UIViewRepresentable {
    let url: URL?
    let onNavigation: (URL) -> Void
    let onError: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView() // Ví dụ: Tạo webView để chuẩn bị tải https://example.com/pay.
        webView.navigationDelegate = context.coordinator // Khi web điều hướng, Coordinator sẽ xử lý (như mở MoMo)
        return webView // Trả webView để hiển thị trang thanh toán
    }
    /*
     Ý nghĩa tổng quát: Đây là một hàm bắt buộc của giao thức UIViewRepresentable, được gọi khi SwiftUI cần tạo một View từ UIKit (ở đây là WKWebView) để hiển thị trong giao diện. Hàm này trả về một instance mới của WKWebView.
     */

    func updateUIView(_ uiView: WKWebView, context: Context) { // Cập nhật webView để tải URL mới
        if let url = url {
            let request = URLRequest(url: url)
            uiView.load(request) // Yêu cầu WKWebView tải trang web từ request. Ví dụ: Tải trang https://example.com/pay vào webView.
        }
    }

    func makeCoordinator() -> Coordinator { // Tạo Coordinator để xử lý điều hướng như momo://pay
        Coordinator(self) // Tạo Coordinator với thông tin từ PaymentWebView chứa url và callbacks
    }

    /* Ý nghĩa tổng quát: Định nghĩa class Coordinator kế thừa từ NSObject (để tuân thủ các giao thức Objective-C như WKNavigationDelegate) và tuân theo giao thức WKNavigationDelegate để xử lý sự kiện điều hướng của WKWebView.
     */
    class Coordinator: NSObject, WKNavigationDelegate { // Class này xử lý khi người dùng nhấp vào link momo://pay.
        let parent: PaymentWebView

        init(_ parent: PaymentWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Kiểm tra nếu URL là Deep Link của MoMo (e.g., momo://)
                if url.scheme == "momo" {
                    // Mở ứng dụng MoMo UAT
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:]) { success in
                            if !success {
                                self.parent.onError("Không thể mở ứng dụng MoMo UAT")
                            }
                        }
                        decisionHandler(.cancel)
                        return
                    }
                }
                // Gọi callback để xử lý navigation
                parent.onNavigation(url)
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError("Lỗi khi tải trang thanh toán: \(error.localizedDescription)")
        }
    }
}
