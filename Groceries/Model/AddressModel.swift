//
//  AddressModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 17/3/25.
//

import SwiftUI

struct AddressModel: Identifiable, Equatable, Codable, Hashable {
    let id: String
    let userId: Int
    let street: String
    let provinceId: Int
    let districtId: Int
    let wardId: Int
    let isDefault: Bool
    // recieved data from server
    init(dict: NSDictionary) {
        // as? return nil if convert fault
        // Lấy giá trị của key "id" từ dict và cố gắng ép kiểu thành String. Dấu as? là optional casting, trả về nil nếu ép kiểu thất bại.
        self.id = dict["id"] as? String ?? UUID().uuidString
        // Safely cast nested dictionaries
        if let userDict = dict["user"] as? [String: Any] {
            self.userId = userDict["id"] as? Int ?? 0
        } else {
            self.userId = 0 // if havent key "user", asaign userId = 0.
        }
        self.street = dict["street"] as? String ?? ""
        if let provinceDict = dict["province"] as? [String: Any] {
            self.provinceId = provinceDict["id"] as? Int ?? 0
        } else {
            self.provinceId = 0
        }
        if let districtDict = dict["district"] as? [String: Any] {
            self.districtId = districtDict["id"] as? Int ?? 0
        } else {
            self.districtId = 0
        }
        if let wardDict = dict["ward"] as? [String: Any] {
            self.wardId = wardDict["id"] as? Int ?? 0
        } else {
            self.wardId = 0
        }
        self.isDefault = dict["isDefault"] as? Bool ?? false
    }
    // initialize new date
    // create object, save on db and send server
    init(id: String = UUID().uuidString, userId: Int, street: String, provinceId: Int, districtId: Int, wardId: Int, isDefault: Bool) {
        self.id = id
        self.userId = userId
        self.street = street
        self.provinceId = provinceId
        self.districtId = districtId
        self.wardId = wardId
        self.isDefault = isDefault
    }
    
    // Triển khai Equatable
    static func ==(lhs: AddressModel, rhs: AddressModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Triển khai Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userId)
        hasher.combine(street)
        hasher.combine(provinceId)
        hasher.combine(districtId)
        hasher.combine(wardId)
        hasher.combine(isDefault)
    }
}

struct ProvinceModel: Identifiable, Hashable, Equatable, Codable {
    let id: Int
    let name: String
    
    static func ==(lhs: ProvinceModel, rhs: ProvinceModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DistrictModel: Identifiable, Hashable, Equatable, Codable {
    let id: Int
    let name: String
    
    static func ==(lhs: DistrictModel, rhs: DistrictModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct WardModel: Identifiable, Hashable, Equatable, Codable {
    let id: Int
    let name: String
    
    static func ==(lhs: WardModel, rhs: WardModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
/*
 {
   "id": "addr123",
   "user": {
     "id": 1
   },
   "street": "123 Main Street",
   "province": {
     "id": 10
   },
   "district": {
     "id": 5
   },
   "ward": {
     "id": 2
   },
   "isDefault": true
 }
 "id": "addr123",
 "user": {
   "id": 1
 },
 "street": "123 Main Street",
 "province": {
   "id": 10
 },
 "district": {
   "id": 5
 },
 "ward": {
   "id": 2
 },
 "isDefault": true
}
 */
