import SwiftUI
import JWTDecode

class MainViewModel: ObservableObject {
    static var shared: MainViewModel = MainViewModel()
    
    // @Published: Khi dữ liệu thay đổi, giao diện sẽ tự động cập nhật.
    @Published var txtFullName: String = ""
    @Published var txtEmail: String = ""
    @Published var txtPassword: String = ""
    @Published var txtPhone: String = ""
    @Published var txtAddress: String = ""
    @Published var isShowPassword: Bool = false
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isUserLogin: Bool = false
    
    @Published var userObj: UserModel = UserModel(dict: [:])
    @Published var token: String = "" // Dùng để lưu tempToken hoặc accessToken
    @Published var refreshToken: String = ""
    
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var navigateTo = false
    @Published var navigateToOTP = false
    @Published var navigationResettoLog = false
    
    // Reset password
    @Published var otpCode: String = ""
    @Published var navigateToLogin = false
    
    // Change password
    @Published var txtOldPassword: String = ""
    
    // Address ViewModel
    @Published var userRole: String = ""
    
    // Thời gian hết hạn của accessToken
    private var tokenExpirationDate: Date? {
        get { Utils.UDValue(key: "tokenExpirationDate") as? Date }
        // Ví dụ: Nếu UserDefaults có key "tokenExpirationDate" với giá trị 2025-06-26 17:00:00, get trả về Date tương ứng. Nếu không có key, trả về nil.
        set { Utils.UDSET(data: newValue, key: "tokenExpirationDate") }
        // Ví dụ: Khi đăng nhập thành công, serviceCallLogin giải mã token và gán tokenExpirationDate = Date(timeIntervalSince1970: 1719483600) (tương ứng 2025-06-27 12:00:00). Giá trị này được lưu vào UserDefaults.
    }
    
    init() {
        if Utils.UDValueBool(key: Globs.userLogin) {
            let userDict = Utils.UDValue(key: Globs.userPayload) as? NSDictionary ?? [:]
            // UserDefaults : "userPayload": {id: 1, email: "user@example.com"}, userDict chứa dictionary này. Nếu không có, userDict = [:].
            self.setUserData(uDict: userDict)
        }
    }
    
    // MARK: - Log In
    func serviceCallLogin() {
        if txtEmail.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid email address"
                self.showError = true
            }
            return
        }
        
        if txtPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid password"
                self.showError = true
            }
            return
        }
        /*
         {
           "message": "Login successful",
           "token": "abc123",
           "refreshToken": "xyz789",
           "user": { "id": 1, "email": "user@example.com" }
         }
         */
        let parameters = ["email": txtEmail, "password": txtPassword]
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_LOGIN) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "Login successful" {
                    self.token = response["token"] as? String ?? "" // response["token"] = "abc123" → self.token = "abc123"
                    self.refreshToken = response["refreshToken"] as? String ?? ""
                    
                    let userDict = response["user"] as? NSDictionary ?? [:] // userDict = {id: 1, email: "user@example.com"}
                    
                    var payloadDict = userDict.mutableCopy() as! NSMutableDictionary // Tạo bản sao có thể chỉnh sửa (NSMutableDictionary) của userDict .mutableCopy(): Tạo bản sao để có thể thêm/sửa key-value.
                    payloadDict["token"] = self.token
                    payloadDict["refreshToken"] = self.refreshToken
                    // {id: 1, email: "user@example.com", token: "abc123", refreshToken: "xyz789"}.
                    
                    // Lưu thời gian hết hạn của access token
                    // self.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJleHAiOjE3MTk0ODM2MDB9..."
                    do {
                        let jwt = try decode(jwt: self.token) // jwt {sub: "123", exp: 1719483600} (2025-06-27 12:00:00).
                        let expClaim = jwt.claim(name: "exp") // expClaim = 1719483600
                        if let exp = expClaim.double { // exp = 1719483600.0 (2025-06-27 12:00:00)
                            self.tokenExpirationDate = Date(timeIntervalSince1970: exp) // convert Date
                            /* exp = 1719483600 → self.tokenExpirationDate = 2025-06-27 12:00:00.
                             Giá trị này được lưu vào UserDefaults với key "tokenExpirationDate". */
                            print("Access token expiration date: \(String(describing: self.tokenExpirationDate))")
                        } else {
                            print("Failed to extract 'exp' claim from access token")
                        }
                    } catch {
                        print("Failed to decode access token: \(error)")
                    }

                    // Giải mã refresh token để lấy thời gian hết hạn
                    // self.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJleHAiOjE3MTk0ODM2MDB9..."
                    do {
                        let jwt = try decode(jwt: self.refreshToken) // jwt {sub: "123", exp: 1719483600} (2025-06-27 12:00:00).
                        let expClaim = jwt.claim(name: "exp") // expClaim = 1719483600
                        if let exp = expClaim.double { // exp = 1719483600.0 (2025-06-27 12:00:00)
                            payloadDict["refreshTokenExpiration"] = Int(exp) // convert Int
                            /* payloadDict["refreshTokenExpiration"] = 1719570000.
                             payloadDict = {id: 1, email: "user@example.com", token: "abc123", refreshToken: "xyz789", refreshTokenExpiration: 1719570000}.*/
                            print("Refresh token expiration date: \(Date(timeIntervalSince1970: exp))")
                        } else {
                            print("Failed to extract 'exp' claim from refresh token")
                        }
                    } catch {
                        print("Failed to decode refresh token: \(error)")
                    }
                    //📍 tokenExpirationDate = 2025-06-27 12:00:00, refreshTokenExpiration = 1719570000
                    self.setUserData(uDict: payloadDict)
                    
                    DispatchQueue.main.async {
                        self.navigateToLogin = false
                        self.navigateTo = true
                    }
                } // if 2
                else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Login failed"
                        self.showError = true
                    }
                }
            } // if 1
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }
    
    // MARK: - Sign Up
    func serviceCallSignUp() {
        if txtFullName.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter your full name"
                self.showError = true
            }
            return
        }

        if !txtEmail.isValidEmail {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid email address"
                self.showError = true
            }
            return
        }

        if txtPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid password"
                self.showError = true
            }
            return
        }

        if txtPhone.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter your phone number"
                self.showError = true
            }
            return
        }

        if txtAddress.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter your address"
                self.showError = true
            }
            return
        }

        let parameters = [
            "fullName": txtFullName,
            "email": txtEmail,
            "password": txtPassword,
            "phone": txtPhone,
            "address": txtAddress
        ]
        // ["fullName": "Nguyễn Văn A", "email": "user@example.com", "password": "pass123", "phone": "0123456789", "address": "Hà Nội"].

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_SIGN_UP) { responseObj in
            if let response = responseObj as? NSDictionary {
                /*{
                 "message": "User registered successfully. Please verify your email with OTP",
                 "user": { "id": 1, "email": "user@example.com" } } */
                if response["message"] as? String == "User registered successfully. Please verify your email with OTP" {
                    // Gọi serviceCallSendOTP và chờ nó hoàn tất
                    self.serviceCallSendOTP { success in
                        if success {
                            // {"message": "OTP has been sent", "tempToken": "otp123"}.
                            var userDict = response["user"] as? NSMutableDictionary ?? NSMutableDictionary()
                            userDict.removeObject(forKey: "refreshToken")
                            userDict["token"] = self.token
                            // self.token: Được gán trong serviceCallSendOTP

                            Utils.UDSET(data: userDict, key: Globs.userPayload) // token được lưu vào UserDefaults
                            // Lưu {id: 1, email: "user@example.com", token: "otp123"} vào UserDefaults với key "userPayload".
                            DispatchQueue.main.async {
                                self.userObj = UserModel(dict: userDict) //UserModel(dict:) (giả định) chỉ lấy các trường cần thiết (như id, email), có thể bỏ qua token khi tạo userObj.
                                self.successMessage = "Registration successful! Please verify your email"
                                self.showSuccess = true
                                self.navigateToOTP = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.errorMessage = "Failed to send OTP after registration"
                                self.showError = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Registration failed"
                        self.showError = true
                    }
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }
    
    /*
     {
         "message": "OTP has been sent",
         "tempToken": "otp123"
     }
     */
    // Sửa đổi serviceCallSendOTP để hỗ trợ callback
        func serviceCallSendOTP(completion: @escaping (Bool) -> Void) {
            let parameters = ["email": txtEmail]

            ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_SEND_OTP) { responseObj in
                if let response = responseObj as? NSDictionary {
                    if response["message"] as? String == "OTP has been sent" {
                        DispatchQueue.main.async {
                            self.token = response["tempToken"] as? String ?? ""
                            self.successMessage = "OTP sent successfully"
                            self.showSuccess = true
                            completion(true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = response["error"] as? String ?? "Failed to send OTP"
                            self.showError = true
                            completion(false)
                        }
                    }
                }
            } failure: { error in
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Network error"
                    self.showError = true
                    completion(false)
                }
            }
        }
        
        // MARK: - Send OTP
        func serviceCallSendOTP() {
            let parameters = ["email": txtEmail]

            ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_SEND_OTP) { responseObj in
                if let response = responseObj as? NSDictionary {
                    if response["message"] as? String == "OTP has been sent" {
                        DispatchQueue.main.async {
                            self.token = response["tempToken"] as? String ?? ""
                            self.successMessage = "OTP sent successfully"
                            self.showSuccess = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = response["error"] as? String ?? "Failed to send OTP"
                            self.showError = true
                        }
                    }
                }
            } failure: { error in
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Network error"
                    self.showError = true
                }
            }
        }
    
    // MARK: - Reset Password
    func serviceCallResetPassword() {
        if txtEmail.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter your email"
                self.showError = true
            }
            return
        }
        
        if otpCode.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter the OTP"
                self.showError = true
            }
            return
        }
        
        if txtPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a new password"
                self.showError = true
            }
            return
        }
        
        let parameters = [
            "tempToken": token,
            "otp": otpCode,
            "newPassword": txtPassword
        ]
        
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_RESET_PASSWORD) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "Your password has been reset successfully." {
                    DispatchQueue.main.async {
                        self.navigationResettoLog = true
                        self.clearSession() // login again
                        self.successMessage = "Your password has updated. Please log in again!"
                        self.showSuccess = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Failed to reset password"
                        self.showError = true
                    }
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }
    // MARK: - Change Password
    func serviceCallChangePassword() {
        guard !userObj.email.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "User email not found. Please log in again."
                self.showError = true
                self.logout()
            }
            return
        }
        
        if txtOldPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter your old password"
                self.showError = true
            }
            return
        }
        
        if txtPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a new password"
                self.showError = true
            }
            return
        }
        
        let parameters = [
            "email": userObj.email,
            "oldPassword": txtOldPassword,
            "newPassword": txtPassword
        ]
        
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_CHANGE_PASSWORD) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "Password changed successfully" {
                    DispatchQueue.main.async {
                        self.successMessage = "Password changed successfully!"
                        self.showSuccess = true
                        self.logout() // Gọi logout() để xóa phiên đăng nhập (như token, refreshToken, userObj, userDict) và điều hướng về màn hình đăng nhập.
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Failed to change password"
                        self.showError = true
                    }
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
            }
        }
    }
    // MARK: - Token Management
    private var isRefreshingToken = false

    private func isTokenExpired() -> Bool {
        guard !token.isEmpty, let expirationDate = tokenExpirationDate else {
            print("Token is empty or expiration date is not set")
            return true
        }
        let isExpired = Date() >= expirationDate
        /* So sánh thời gian hiện tại (Date()) với tokenExpirationDate. Nếu hiện tại lớn hơn hoặc bằng, token đã hết hạn.
         Nếu tokenExpirationDate = 2025-06-27 17:00:00 và hiện tại là 2025-06-27 17:48:00, isExpired = true */
        print("Token expiration check: \(isExpired ? "Expired" : "Valid") - Expiration Date: \(expirationDate)")
        return isExpired // Trả về true để kích hoạt làm mới token || false nếu còn hợp lệ
    }

    private func isRefreshTokenExpired() -> Bool {
        guard let userDict = Utils.UDValue(key: Globs.userPayload) as? NSDictionary,
              let exp = userDict["refreshTokenExpiration"] as? Int else {
            print("Refresh token expiration date not set")
            return true
        }
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(exp)) // exp = 1719573600 → expirationDate = 2025-06-28 17:00:00.
        let isExpired = Date() >= expirationDate // Nếu hiện tại lớn hơn hoặc bằng, refresh token đã hết hạn.
        print("Refresh token expiration check: \(isExpired ? "Expired" : "Valid") - Expiration Date: \(expirationDate)")
        return isExpired
    }

    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard !isRefreshingToken else { // Nếu không đang làm mới (!isRefreshingToken = true), tiếp tục thực thi hàm. Nếu đang làm mới (!isRefreshingToken = false), chạy block else
            print("Already refreshing token, skipping duplicate request")
            completion(false)
            return
        }

        guard !refreshToken.isEmpty else {
            // Nếu có giá trị (!refreshToken.isEmpty = true), tiếp tục hàm. Nếu rỗng (!refreshToken.isEmpty = false), chạy block else.
            // Nếu refreshToken rỗng (do chưa đăng nhập, clearSession(), hoặc lỗi), không thể làm mới token, nên phải đăng xuất để yêu cầu đăng nhập lại.
            print("Refresh token is empty, cannot refresh access token")
            DispatchQueue.main.async {
                self.errorMessage = "Session expired. Please log in again."
                self.showError = true
                self.logout()
            }
            completion(false)
            return
        }

        if isRefreshTokenExpired() { // true nếu refresh token hết hạn, false nếu còn hợp lệ
            print("Refresh token has expired, logging out user")
            DispatchQueue.main.async {
                self.errorMessage = "Session expired. Please log in again."
                self.showError = true
                self.logout()
            }
            completion(false)
            return
        }

        isRefreshingToken = true
        let parameters = ["refreshToken": refreshToken]
        print("Refreshing access token with refreshToken: \(refreshToken)")

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_REFRESH) { responseObj in // Gửi refreshToken để nhận access token mới.
            self.isRefreshingToken = false
            if let response = responseObj as? NSDictionary { // responseObj = {"accessToken": "new123", "expiresIn": 3600}
                if let newAccessToken = response["accessToken"] as? String {
                    print("New access token received: \(newAccessToken)")
                    DispatchQueue.main.async {
                        self.token = newAccessToken
                        do {
                            let jwt = try decode(jwt: newAccessToken) // {exp: 1719667500} (3:00 PM ngày 28/6/2025)
                            let expClaim = jwt.claim(name: "exp") // expClaim = 1719667500
                            if let exp = expClaim.double {
                                self.tokenExpirationDate = Date(timeIntervalSince1970: exp)
                                // exp = 1719667500 (3:00 PM ngày 28/6/2025). Dòng này đặt tokenExpirationDate = 2025-06-28 15:00:00. Minh dùng token đến 3:00 PM
                                print("New token expiration date: \(String(describing: self.tokenExpirationDate))")
                            } else {
                                let expiresIn = response["expiresIn"] as? Int ?? 3600
                                self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                                print("New token expiration date (default): \(String(describing: self.tokenExpirationDate))")
                            }
                        } catch {
                            print("Failed to decode new access token: \(error)")
                            let expiresIn = response["expiresIn"] as? Int ?? 3600 // expiresIn = 7200. Nếu không có expiresIn, dùng 3600
                            self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn)) // expiresIn = 7200, hiện tại là 02:15 PM. tokenExpirationDate = 2025-06-28 16:15:00.
                            print("New token expiration date (default): \(String(describing: self.tokenExpirationDate))")
                        }
                        if let userDict = Utils.UDValue(key: Globs.userPayload) as? NSMutableDictionary {
                            userDict["token"] = self.token
                            Utils.UDSET(data: userDict, key: Globs.userPayload) // Cập nhật token trong userDict, lưu vào UserDefaults
                            print("Updated token in UserDefaults")
                        }
                    }
                    completion(true)
                } else {
                    print("Failed to refresh token: No access token in response")
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to refresh token"
                        self.showError = true
                        self.logout()
                    }
                    completion(false)
                }
            } else {
                print("Failed to refresh token: Invalid response format")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to refresh token"
                    self.showError = true
                    self.logout()
                }
                completion(false)
            }
        } failure: { error in
            self.isRefreshingToken = false
            print("Failed to refresh token: Network error - \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                self.logout()
            }
            completion(false)
        }
    }

    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    public func callApiWithTokenCheck(method: HTTPMethod, path: String, parameters: NSDictionary, withSuccess: @escaping (Any?) -> Void, failure: @escaping (Error?) -> Void) {
        // Minh đăng nhập lúc 01:00 PM, nhận token = "abc123" (hết hạn 02:00 PM) và refreshToken = "xyz789".
        // Tại 02:53 PM, isTokenExpired() = true (token hết hạn), !refreshToken.isEmpty = true (có refresh token). Block if chạy.
        if isTokenExpired() && !refreshToken.isEmpty {
            print("Token expired, attempting to refresh token before calling API: \(path)")
            refreshAccessToken { success in
                if success {
                    print("Token refreshed successfully, proceeding with API call: \(path)")
                    self.performApiCall(method: method, path: path, parameters: parameters, withSuccess: withSuccess, failure: failure)
                } else {
                    print("Failed to refresh token, API call aborted: \(path)")
                    failure(nil)
                }
            }
        } else if token.isEmpty {
            print("No token available, user must log in again")
            DispatchQueue.main.async {
                self.errorMessage = "Session expired. Please log in again."
                self.showError = true
                self.logout()
            }
            failure(nil)
        } else {
            print("Token is valid, proceeding with API call: \(path)")
            self.performApiCall(method: method, path: path, parameters: parameters, withSuccess: withSuccess, failure: failure)
        }
    }

    private func performApiCall(method: HTTPMethod, path: String, parameters: NSDictionary, withSuccess: @escaping (Any?) -> Void, failure: @escaping (Error?) -> Void) {
        switch method {
        case .get:
            ServiceCall.get(path: path, withSuccess: { responseObj in
                print("GET API call successful: \(path) - Response: \(String(describing: responseObj))")
                withSuccess(responseObj)
            }, failure: { error in
                print("GET API call failed: \(path) - Error: \(error?.localizedDescription ?? "Unknown error")")
                failure(error)
            })
        case .post:
            ServiceCall.post(parameter: parameters, path: path) { responseObj in
                print("POST API call successful: \(path) - Response: \(String(describing: responseObj))")
                withSuccess(responseObj)
            } failure: { error in
                print("POST API call failed: \(path) - Error: \(error?.localizedDescription ?? "Unknown error")")
                failure(error)
            }
        case .delete:
            ServiceCall.delete(path: path, withSuccess: { responseObj in
                print("DELETE API call successful: \(path) - Response: \(String(describing: responseObj))")
                withSuccess(responseObj)
            }, failure: { error in
                print("DELETE API call failed: \(path) - Error: \(error?.localizedDescription ?? "Unknown error")")
                failure(error)
            })
        }
    }
    
    // Logout
    func logout() {
        DispatchQueue.main.async {
            self.clearSession()
            self.isUserLogin = false // make sure User Login
            self.navigateToLogin = true
            self.navigateTo = false
            self.navigateToOTP = false
        }
    }
        
    // Delete session/tempToken
    func clearSession() {
        self.token = ""
        self.refreshToken = ""
        self.isUserLogin = false
        
        self.userObj = UserModel(dict: [:]) // Xóa thông tin người dùng (như id, email).
        self.navigateTo = false
        
        self.txtEmail = ""
        self.txtPassword = ""
        self.txtOldPassword = ""
        self.txtFullName = ""
        self.txtPhone = ""
        self.txtAddress = ""
        self.isShowPassword = false
        self.otpCode = ""
        
        self.showError = false
        self.errorMessage = ""
        self.showSuccess = false
        self.successMessage = ""
        
        // Lưu vào UserDefaults
        Utils.UDSET(data: false, key: Globs.userLogin) // để đánh dấu chưa đăng nhập.
        Utils.UDSET(data: [:], key: Globs.userPayload) // để xóa thông tin người dùng.
        Utils.UDSET(data: 0, key: "userId") // để xóa ID người dùng.
    }

    // MARK: - Set User Data
    func setUserData(uDict: NSDictionary) {
        if let userId = uDict["id"] as? Int {
            Utils.UDSET(data: userId, key: "userId") // uDict["id"] = 1 → UserDefaults.standard.set(1, forKey: "userId").
            print("Stored userId in UserDefaults: \(userId)")
        } else {
            print("Failed to store userId: 'id' not found in user dictionary")
        }
        
        Utils.UDSET(data: uDict, key: Globs.userPayload)
        // Lưu toàn bộ uDict vào UserDefaults : uDict["id"] = 1 → UserDefaults.standard.set(1, forKey: "userId").
        Utils.UDSET(data: true, key: Globs.userLogin)
        // Đặt true vào UserDefaults với key Globs.userLogin để đánh dấu đã đăng nhập.
        
        DispatchQueue.main.async {
            self.userObj = UserModel(dict: uDict) // Tạo UserModel từ uDict : userObj chứa id: 1, email: "user@example.com"
            self.isUserLogin = true
            self.token = uDict["token"] as? String ?? ""
            self.refreshToken = uDict["refreshToken"] as? String ?? ""
            
            self.userRole = uDict["role"] as? String ?? "" // uDict["role"] = "ADMIN" → userRole = "ADMIN"
            
            self.txtFullName = ""
            self.txtEmail = ""
            self.txtPassword = ""
            self.txtPhone = ""
            self.txtAddress = ""
            self.isShowPassword = false
            // Xóa các @Published properties liên quan đến UI nhập liệu để làm sạch sau đăng nhập.
        }
    }
    
    func setUser(uDict: NSDictionary) { // giống setUserData nhưng không lưu token, refreshToken, userRole.
        if let userId = uDict["id"] as? Int {
            Utils.UDSET(data: userId, key: "userId")
            print("Stored userId in UserDefaults: \(userId)")
        } else {
            print("Failed to store userId: 'id' not found in user dictionary")
        }
        
        Utils.UDSET(data: uDict, key: Globs.userPayload)
        Utils.UDSET(data: true, key: Globs.userLogin)

        DispatchQueue.main.async {
            self.userObj = UserModel(dict: uDict)
            self.isUserLogin = true
            
            self.txtFullName = ""
            self.txtEmail = ""
            self.txtPassword = ""
            self.isShowPassword = false
        }
    }
    
    func isAdmin() -> Bool {
        return userRole == "ADMIN"
    }
}
