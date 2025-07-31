//  ReviewViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/4/25.
//

import SwiftUI

class ReviewViewModel: ObservableObject {
    static let shared = ReviewViewModel()

    @Published var listArr: [ReviewModel] = []
    @Published var showError = false
    @Published var errorMessage = ""

    // Lay danh sach danh gia cua san pham
    func fetchReviews(productId: Int, completion: @escaping () -> Void) {
        let path = "\(Globs.BASE_URL)reviews/\(productId)"
        print("Token before API call: \(MainViewModel.shared.token)")
        
        // Reset trạng thái trước khi fetch. Đảm bảo bắt đầu với trạng thái sạch, tránh hiển thị dữ liệu lỗi từ lần gọi trước.
        self.showError = false
        self.errorMessage = ""
        self.listArr = []
        
        ServiceCall.get(path: path, withSuccess: { response in
            print("Reviews API Response for productId \(productId): \(String(describing: response))")
            guard let reviewsArray = response as? NSArray else {
                self.errorMessage = "Failed to parse reviews: Expected an array."
                self.showError = true
                completion()
                return
            }

            self.listArr = reviewsArray.compactMap { item in
                guard let dict = item as? NSDictionary else {
                    print("Failed to parse review item as dictionary: \(item)")
                    return nil
                }
                return ReviewModel(dict: dict)
            }
            print("Parsed reviews: \(self.listArr)")
            completion()
        }, failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Failed to fetch reviews."
            self.showError = true
            print("Fetch reviews error: \(self.errorMessage)")
            completion()
        })
    }

    // Them danh gia moi
    func addReview(productId: Int, rating: Float, comment: String? = nil, completion: @escaping (Bool, String) -> Void) {
        let path = "\(Globs.BASE_URL)reviews"
        let params: [String: Any] = [
            "productId": productId,
            "rating": rating,
            "comment": comment ?? NSNull()
        ]

        ServiceCall.post(parameter: params as NSDictionary, path: path, withSuccess: { response in
            guard let dict = response as? NSDictionary,
                  let status = dict.value(forKey: KKey.status) as? Bool,
                  status == true else {
                let message = (response as? NSDictionary)?.value(forKey: KKey.message) as? String ?? "Failed to add review."
                completion(false, message)
                return
            }

            completion(true, "Review added successfully!")
        }, failure: { error in
            completion(false, error?.localizedDescription ?? "Failed to add review.")
        })
    }

    // Kiem tra xem nguoi dung da mua san pham va don hang da hoan tat chua
    func canUserReview(productId: Int, completion: @escaping (Bool) -> Void) {
        let path = "\(Globs.SV_MY_ORDERS_LIST)"
        ServiceCall.get(path: path, withSuccess: { response in
            guard let dict = response as? NSDictionary,
                  let payload = dict.value(forKey: KKey.payLoad) as? NSDictionary,
                  let content = payload["content"] as? NSArray else {
                /*
                 {
                   "payLoad": {
                     "content": [
                       { "orderId": 123, "status": "COMPLETED", "items": [{"productId": 123, "rating": 0}] },
                       ...
                     ]
                   }
                 }
                 */
                completion(false)
                return
            }

            let orders = content.map { MyOrderModel(dict: $0 as? NSDictionary ?? [:]) }
            // orders = [MyOrderModel(id: 123, status: "COMPLETED", items: [OrderItem(productId: 123, rating: 0)])]
            let canReview = orders.contains { order in
                order.status == "COMPLETED" && order.items.contains { item in
                    item.productId == productId && item.rating == 0
                    // productId = 123, orders = [MyOrderModel(status: "COMPLETED", items: [OrderItem(productId: 123, rating: 0)])].
                }
            }
            completion(canReview)
        }, failure: { _ in
            completion(false)
        })
    }
}
