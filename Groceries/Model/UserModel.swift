//
//  UserModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 5/12/24.
//

import SwiftUI
struct UserModel {
    var id: Int
    var fullName: String
    var email: String
    var role: String
    var phone: String
    var address: String
    var token: String?
    var refreshToken: String?
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as? Int ?? 0
        self.fullName = dict["fullName"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.role = dict["role"] as? String ?? ""
        self.phone = dict["phone"] as? String ?? ""
        self.address = dict["address"] as? String ?? ""
        self.token = dict["token"] as? String ?? ""
        self.refreshToken = dict["refreshToken"] as? String
    }
    
    func toDict() -> NSDictionary {
        var dict: [String: Any] = [
            "id": id,
            "fullName": fullName,
            "email": email,
            "role": role,
            "phone": phone,
            "address": address
        ]
        if let token = token {
            dict["token"] = token
        }
        if let refreshToken = refreshToken {
            dict["refreshToken"] = refreshToken
        }
        return dict as NSDictionary
    }
}
