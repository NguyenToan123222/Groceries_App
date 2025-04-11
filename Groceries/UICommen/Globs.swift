//
//  Globs.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 22/9/24.
//

import SwiftUI

struct Globs {
    static let AppName = "Online Groceries"
    static let BASE_URL = "http://localhost:8081/api/"
    
    static let userPayload = "user_payload"
    static let userLogin = "user_login"

// http://localhost:3001/api/app/login
    static let SV_LOGIN = BASE_URL + "auth/login"
    static let SV_SIGN_UP = BASE_URL + "auth/register"
    static let SV_SEND_OTP = BASE_URL + "auth/send-otp"
    static let SV_VERIFY_OTP = BASE_URL + "auth/verify-otp"
    static let SV_RESET_PASSWORD = BASE_URL + "auth/reset-password"
    static let SV_CHANGE_PASSWORD = BASE_URL + "auth/change-password"
    static let SV_REFRESH = BASE_URL + "auth/refresh"

    static let SV_HOME = BASE_URL + "products"
    static let SV_BEST_SELLING = BASE_URL + "best-selling"
    static let SV_EXCLUSIVE_OFFER = BASE_URL + "offers"

    
    static let SV_PRODUCT_DETAIL = BASE_URL + "products/{id}"
    static let SV_ADD_PRODUCT = BASE_URL + "products" // Thêm sản phẩm (POST)
    static let SV_UPDATE_PRODUCT = BASE_URL + "products/{id}" // Sửa sản phẩm (PUT)
    static let SV_DELETE_PRODUCT = BASE_URL + "products/{id}" // Xóa sản phẩm (DELETE)
    static let SV_FILTER_PRODUCTS = BASE_URL + "products/filter" // Lọc sản phẩm
    
    static let SV_CATEGORIES = BASE_URL + "categories"
    static let SV_BRANDS = BASE_URL + "brands"
    
    static let SV_FAVORITE_LIST = BASE_URL + "favorites"
    static let SV_ADD_FAVORITE = BASE_URL + "favorites/{productId}" 
    static let SV_REMOVE_FAVORITE = BASE_URL + "favorites/{productId}"

    static let SV_EXPLORE_LIST = BASE_URL + "explore_list"
    static let SV_EXPLORE_ITEMS_LIST = BASE_URL + "explore_items_list"

    static let SV_CART_LIST = BASE_URL + "cart" // GET /api/cart
    static let SV_ADD_CART = BASE_URL + "cart/add" // POST /api/cart/add
    static let SV_UPDATE_CART = BASE_URL + "cart/update" // PUT /api/cart/update
    static let SV_REMOVE_CART = BASE_URL + "cart/remove" // DELETE /api/cart/remove
    static let SV_CART_COUNT = BASE_URL + "cart/count" // GET /api/cart/count (nếu cần)

    static let SV_ADDRESS_LIST = BASE_URL + "add_to_cart"
    static let SV_REMOVE_ADDRESS = BASE_URL + "add_to_cart"
    static let SV_UPDATE_ADDRESS = BASE_URL + "add_to_cart"
    static let SV_ADD_ADDRESS = BASE_URL + "add_to_cart"

    static let SV_PROMO_CODE_LIST = BASE_URL + "add_to_cart"

    static let SV_PAYMENT_METHOD_LIST = BASE_URL + "add_to_cart"
    static let SV_REMOVE_PAYMENT_METHOD = BASE_URL + "add_to_cart"
    static let SV_ADD_PAYMENT_METHOD = BASE_URL + "add_to_cart"

    static let SV_ORDER_PLACE = BASE_URL + "check_out"
    static let SV_MY_ORDERS_DETAIL = BASE_URL + "check_out"
    static let SV_MY_ORDERS_LIST = BASE_URL + "check_out"

    static let SV_NOTIFICATION_LIST = BASE_URL + "check_out"
    static let SV_NOTIFICATION_READ_ALL = BASE_URL + "check_out"

    

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

