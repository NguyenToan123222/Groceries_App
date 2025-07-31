//  ReviewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/4/25.
//

import SwiftUI

struct ReviewModel: Identifiable, Equatable {
    var id: Int = 0
    var userId: Int = 0
    var productId: Int = 0
    var rating: Float = 0.0
    var comment: String?
    var createdAt: Date = Date()

    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? Int ?? 0
        self.userId = dict.value(forKey: "userId") as? Int ?? 0
        self.productId = dict.value(forKey: "productId") as? Int ?? 0
        self.rating = dict.value(forKey: "rating") as? Float ?? 0.0
        self.comment = dict.value(forKey: "comment") as? String
        // Xu ly ngay gio tu chuoi ISO8601
        if let createdAtStr = dict.value(forKey: "createdAt") as? String {
            self.createdAt = createdAtStr.iso8601toDate() ?? Date()
        } else {
            self.createdAt = Date()
        }
    }

    static func == (lhs: ReviewModel, rhs: ReviewModel) -> Bool {
        return lhs.id == rhs.id
    }
}



extension Date {
    func displayDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
