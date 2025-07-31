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
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
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
