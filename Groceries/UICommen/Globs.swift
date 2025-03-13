//
//  Globs.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 22/9/24.
//

import SwiftUI

struct Globs {
    static let AppName = "Online Groceries"
    static let BASE_URL = "http://localhost:8081/api/auth/"
    
    static let userPayload = "user_payload"
    static let userLogin = "user_login"

// http://localhost:3001/api/app/login
    static let SV_LOGIN = BASE_URL + "login"
    static let SV_SIGN_UP = BASE_URL + "register"
    static let SV_HOME = BASE_URL + "home"
    static let SV_SEND_OTP = BASE_URL + "send-otp"
    static let SV_VERIFY_OTP = BASE_URL + "verify-otp"
    static let SV_RESET_PASSWORD = BASE_URL + "reset-password"
    static let SV_CHANGE_PASSWORD = BASE_URL + "change-password"
    static let SV_REFRESH = BASE_URL + "refresh"

    static let SV_PRODUCT_DETAIL = BASE_URL + "product-detail"
    static let SV_ADD_REMOVE_FAVORITE = BASE_URL + "add_remove_favorite"
    static let SV_FAVORITE_LIST = BASE_URL + "favorite_list"

    static let SV_EXPLORE_LIST = BASE_URL + "explore_list"
    static let SV_EXPLORE_ITEMS_LIST = BASE_URL + "explore_items_list"

    
    
    



}

struct KKey {
    static let status = "status"
    static let message = "message"
    static let payLoad = "payload"
}

class Utils {
    class func UDSET(data: Any, key: String) {
        // Điều này lưu giá trị true (đã đăng nhập) với key "user_login".
        UserDefaults.standard.set(data, forKey: key)
        
       // Đồng bộ dữ liệu ngay lập tức (không bắt buộc, vì UserDefaults tự động đồng bộ).
        UserDefaults.standard.synchronize()
        /*
         Utils.UDSET(data: "John Doe", key: "username") // Lưu tên người dùng
         Utils.UDSET(data: true, key: "isLoggedIn") // Lưu trạng thái đăng nhập
         Utils.UDSET(data: 25, key: "userAge") // Lưu tuổi của người dùng
         */
    }

    class func UDValue(key: String) -> Any { // Any : AnyType
        return UserDefaults.standard.value(forKey: key) as Any
        // let username = Utils.UDValue(key: "username") // Trả về "John Doe"
    }
    
    // let isLoggedIn = Utils.UDValueBool(key: Globs.userLogin) // Trả về true hoặc false : default: false
    class func UDValueBool(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? false // Nếu không tìm thấy giá trị (nil), trả về false (mặc định).
    }
    
    // let isSubscribed = Utils.UDValueTrueBool(key: "subscription") // Trả về true nếu không có dữ liệu
    // true if not data
    class func UDValueTrueBool(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? true
    }
    
    
    class func UDRemove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}

