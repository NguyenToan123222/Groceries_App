//
//  UserModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 5/12/24.
//

import SwiftUI

struct UserModel: Identifiable {
    var id: Int
    var fullName: String
    var email: String
    var role: String
    var phone: String
    var address: String
    var token: String?
    var refreshToken: String?
    let createdAt: Date
    let isVerified: Bool
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as? Int ?? 0
        self.fullName = dict["fullName"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        // Ánh xạ role từ roleName
        if let roleDict = dict["role"] as? NSDictionary,
           let roleName = roleDict["roleName"] as? String {
            self.role = roleName
        } else {
            self.role = ""
        }
        self.phone = dict["phone"] as? String ?? ""
        // Ánh xạ addresses thành chuỗi
        if let addresses = dict["addresses"] as? [NSDictionary],
           !addresses.isEmpty,
           let firstAddress = addresses.first,
           let street = firstAddress["street"] as? String,
           let ward = firstAddress["ward"] as? NSDictionary,
           let wardName = ward["name"] as? String,
           let district = firstAddress["district"] as? NSDictionary,
           let districtName = district["name"] as? String,
           let province = firstAddress["province"] as? NSDictionary,
           let provinceName = province["name"] as? String {
            self.address = "\(street), \(wardName), \(districtName), \(provinceName)"
        } else {
            self.address = ""
        }
        self.token = dict["token"] as? String ?? ""
        self.refreshToken = dict["refreshToken"] as? String
        self.isVerified = dict["isVerified"] as? Bool ?? false
        let createdAtString = dict["createdAt"] as? String ?? ""
        self.createdAt = createdAtString.iso8601Date() ?? Date()
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
/*
 {
   "id": 1,
   "fullName": "Nguyễn Văn A",
   "email": "a@example.com",
   "role": {
     "roleName": "customer"
   },
   "phone": "0123456789",
   "addresses": [
     {
       "street": "123 Đường Láng",
       "ward": { "name": "Nghĩa Đô" },
       "district": { "name": "Cầu Giấy" },
       "province": { "name": "Hà Nội" }
     }
   ],
   "token": "abc123",
   "isVerified": true,
   "createdAt": "2024-12-05T00:00:00Z"
 }
 */
