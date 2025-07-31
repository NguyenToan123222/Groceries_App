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

    // User-related keys
    static let userPayload = "user_payload"
    static let userLogin = "user_login"

    // Address-related endpoints
    static let SV_GET_PROVINCES = BASE_URL + "addresses/provinces"
    static let SV_GET_DISTRICTS = BASE_URL + "addresses/districts"
    static let SV_GET_WARDS = BASE_URL + "addresses/wards"
    static let SV_ADDRESS_LIST = BASE_URL + "addresses"
    static let SV_ADD_ADDRESS = BASE_URL + "addresses/add"
    static let SV_UPDATE_ADDRESS = BASE_URL + "addresses"
    static let SV_REMOVE_ADDRESS = BASE_URL + "addresses"

    // Authentication endpoints
    static let SV_LOGIN = BASE_URL + "auth/login"
    static let SV_SIGN_UP = BASE_URL + "auth/register"
    static let SV_SEND_OTP = BASE_URL + "auth/send-otp"
    static let SV_VERIFY_OTP = BASE_URL + "auth/verify-otp"
    static let SV_RESET_PASSWORD = BASE_URL + "auth/reset-password"
    static let SV_CHANGE_PASSWORD = BASE_URL + "auth/change-password"
    static let SV_REFRESH = BASE_URL + "auth/refresh"

    // Product-related endpoints
    static let SV_HOME = BASE_URL + "products"
    static let SV_BEST_SELLING = BASE_URL + "best-selling"
    static let SV_EXCLUSIVE_OFFER = BASE_URL + "offers"
    static let SV_PRODUCT_DETAIL = BASE_URL + "products/{id}"
    static let SV_ADD_PRODUCT = BASE_URL + "products"
    static let SV_UPDATE_PRODUCT = BASE_URL + "products/{id}"
    static let SV_DELETE_PRODUCT = BASE_URL + "products/{id}"
    static let SV_FILTER_PRODUCTS = BASE_URL + "products/filter"

    // Category and brand endpoints
    static let SV_CATEGORIES = BASE_URL + "categories"
    static let SV_BRANDS = BASE_URL + "brands"
    static let SV_NUTRITIONS = BASE_URL + "nutritions"
    static let SV_ADD_NUTRITION = BASE_URL + "nutritions" // Added endpoint for adding nutrition
    static let SV_DELETE_NUTRITION = BASE_URL + "nutritions/{id}" // Added endpoint for adding nutrition

    // Favorite endpoints
    static let SV_FAVORITE_LIST = BASE_URL + "favorites"
    static let SV_ADD_FAVORITE = BASE_URL + "favorites/{productId}"
    static let SV_REMOVE_FAVORITE = BASE_URL + "favorites/{productId}"

    // Cart endpoints
    static let SV_CART_LIST = BASE_URL + "cart"
    static let SV_ADD_CART = BASE_URL + "cart/add"
    static let SV_UPDATE_CART = BASE_URL + "cart/update"
    static let SV_REMOVE_CART = BASE_URL + "cart/remove"
    static let SV_CART_COUNT = BASE_URL + "cart/count"

    // Order-related endpoints
    static let SV_ORDER_PLACE = BASE_URL + "orders/customer/place" // Đặt hàng
    static let SV_MY_ORDERS_LIST = BASE_URL + "orders/customer" // Lấy danh sách đơn hàng
    static let SV_MY_ORDERS_DETAIL = BASE_URL + "orders/customer/" // Lấy chi tiết đơn hàng (cần thêm {orderId})

    // Payment-related endpoints (Cập nhật để khớp với BE)
    static let SV_CREATE_PAYMENT = BASE_URL + "payments/create"
    static let SV_CONFIRM_PAYMENT = BASE_URL + "payments/confirm"
    static let SV_CANCEL_PAYMENT = BASE_URL + "payments/cancel"
    static let SV_VERIFY_PAYMENT = BASE_URL + "payments/verify"

    // Other endpoints (placeholders)
    static let SV_EXPLORE_LIST = BASE_URL + "explore_list"
    static let SV_EXPLORE_ITEMS_LIST = BASE_URL + "explore_items_list"
    
    // Review-related endpoints
    static let SV_REVIEWS = BASE_URL + "reviews" // Thêm endpoint cho reviews

    static let SV_PROMO_CODE_LIST = BASE_URL + "promo_codes"
    
    static let SV_NOTIFICATION_LIST = BASE_URL + "notifications"
    static let SV_NOTIFICATION_READ_ALL = BASE_URL + "notifications/read-all"

    // Admin order endpoints
    static let SV_ADMIN_ORDERS_LIST = BASE_URL + "orders/admin/all"
    static let SV_ADMIN_ORDER_STATISTICS = BASE_URL + "orders/admin/statistics"
    static let SV_ADMIN_ORDER_STATUSES = BASE_URL + "orders/admin/statuses"
    static let SV_ADMIN_UPDATE_ORDER_STATUS = BASE_URL + "orders/admin/{orderId}/status"
    static let SV_ADMIN_COMPLETE_COD = BASE_URL + "orders/customer/{orderId}/complete-cod"
}

struct KKey {
    static let status = "status"
    static let message = "message"
    static let payLoad = "payload"
}

class Utils {
    // Save data to UserDefaults
    class func UDSET(data: Any, key: String) {
        UserDefaults.standard.set(data, forKey: key) // Lưu data vào UserDefaults với khóa key
        UserDefaults.standard.synchronize()
    }
    
    // Retrieve data from UserDefaults : Truy xuất dữ liệu đã lưu
    class func UDValue(key: String) -> Any? { // -> Any?: Trả về dữ liệu kiểu Any? (có thể là nil nếu không có dữ liệu).
        return UserDefaults.standard.value(forKey: key) // Lấy giá trị tương ứng với key từ UserDefaults.
    }
    
    // Retrieve boolean from UserDefaults, default to false
    class func UDValueBool(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? false
    }
    
    // Retrieve boolean from UserDefaults, default to true
    class func UDValueTrueBool(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? true
    }
    
    // Remove data from UserDefaults
    class func UDRemove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
