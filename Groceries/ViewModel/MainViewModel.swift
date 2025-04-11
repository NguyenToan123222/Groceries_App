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
    @Published var token: String = ""
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
    
    @Published var userRole: String = ""
    
    // Thời gian hết hạn của accessToken
    private var tokenExpirationDate: Date? {
        get { Utils.UDValue(key: "tokenExpirationDate") as? Date }
        set { Utils.UDSET(data: newValue, key: "tokenExpirationDate") }
    }
    
    init() {
        if Utils.UDValueBool(key: Globs.userLogin) {
            let userDict = Utils.UDValue(key: Globs.userPayload) as? NSDictionary ?? [:]
            self.setUserData(uDict: userDict)
        }
    }
    
    // MARK: Log In
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
        
        let parameters = ["email": txtEmail, "password": txtPassword]
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_LOGIN) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "Login successful" {
                    self.token = response["token"] as? String ?? ""
                    self.refreshToken = response["refreshToken"] as? String ?? ""
                    
                    let userDict = response["user"] as? NSDictionary ?? [:]
                    
                    var payloadDict = userDict.mutableCopy() as! NSMutableDictionary
                    payloadDict["token"] = self.token
                    payloadDict["refreshToken"] = self.refreshToken
                    
                    // Lưu thời gian hết hạn của access token
                    do {
                        let jwt = try decode(jwt: self.token)
                        let expClaim = jwt.claim(name: "exp")
                        if let exp = expClaim.double {
                            self.tokenExpirationDate = Date(timeIntervalSince1970: exp)
                            print("Access token expiration date: \(String(describing: self.tokenExpirationDate))")
                        } else {
                            print("Failed to extract 'exp' claim from access token")
                        }
                    } catch {
                        print("Failed to decode access token: \(error)")
                    }

                    // Giải mã refresh token để lấy thời gian hết hạn
                    do {
                        let jwt = try decode(jwt: self.refreshToken)
                        let expClaim = jwt.claim(name: "exp")
                        if let exp = expClaim.double {
                            payloadDict["refreshTokenExpiration"] = Int(exp)
                            print("Refresh token expiration date: \(Date(timeIntervalSince1970: exp))")
                        } else {
                            print("Failed to extract 'exp' claim from refresh token")
                        }
                    } catch {
                        print("Failed to decode refresh token: \(error)")
                    }
                    
                    self.setUserData(uDict: payloadDict)
                    
                    DispatchQueue.main.async {
                        self.navigateToLogin = false
                        self.navigateTo = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = response["error"] as? String ?? "Login failed"
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

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_SIGN_UP) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "User registered successfully. Please verify your email with OTP" {
                    self.serviceCallSendOTP()

                    var userDict = response["user"] as? NSMutableDictionary ?? NSMutableDictionary()
                    userDict.removeObject(forKey: "refreshToken")
                    userDict["token"] = self.token

                    Utils.UDSET(data: userDict, key: Globs.userPayload)
                    DispatchQueue.main.async {
                        self.userObj = UserModel(dict: userDict)
                        self.successMessage = "Registration successful! Please verify your email"
                        self.showSuccess = true
                        self.navigateToOTP = true
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
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            var request = URLRequest(url: URL(string: Globs.SV_RESET_PASSWORD)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                        return
                    }
                    
                    guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                        self.errorMessage = "Invalid response"
                        self.showError = true
                        return
                    }
                    
                    print("Reset Password Response: \(responseString)")
                    if responseString == "Your password has been reset successfully." {
                        self.navigationResettoLog = true
                        self.clearSession()
                        self.successMessage = "Your password has updated. Please log in again!"
                        self.showSuccess = true
                    } else {
                        self.errorMessage = responseString
                        self.showError = true
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to serialize request: \(error.localizedDescription)"
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
            "email": self.userObj.email,
            "oldPassword": txtOldPassword,
            "newPassword": txtPassword
        ]
        
        var components = URLComponents(string: Globs.SV_CHANGE_PASSWORD)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.showError = true
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }
                
                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    self.errorMessage = "Invalid response"
                    self.showError = true
                    return
                }
                
                print("Change Password Response: \(responseString)")
                if responseString == "Password changed successfully" {
                    self.successMessage = "Password changed successfully!"
                    self.showSuccess = true
                    self.logout()
                    self.navigateToLogin = true
                } else {
                    self.errorMessage = responseString
                    self.showError = true
                }
            }
        }.resume()
    }
    
    // MARK: - Token Management
    /// Biến để theo dõi trạng thái làm mới token
    private var isRefreshingToken = false

    /// Kiểm tra xem token có hết hạn hay không
    private func isTokenExpired() -> Bool {
        guard !token.isEmpty, let expirationDate = tokenExpirationDate else {
            print("Token is empty or expiration date is not set")
            return true
        }
        let isExpired = Date() >= expirationDate
        print("Token expiration check: \(isExpired ? "Expired" : "Valid") - Expiration Date: \(expirationDate)")
        return isExpired
    }

    /// Kiểm tra xem refresh token có hết hạn hay không
    private func isRefreshTokenExpired() -> Bool {
        guard let userDict = Utils.UDValue(key: Globs.userPayload) as? NSDictionary,
              let exp = userDict["refreshTokenExpiration"] as? Int else {
            print("Refresh token expiration date not set")
            return true
        }
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(exp))
        let isExpired = Date() >= expirationDate
        print("Refresh token expiration check: \(isExpired ? "Expired" : "Valid") - Expiration Date: \(expirationDate)")
        return isExpired
    }

    /// Làm mới access token bằng refresh token
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard !isRefreshingToken else {
            print("Already refreshing token, skipping duplicate request")
            completion(false)
            return
        }

        guard !refreshToken.isEmpty else {
            print("Refresh token is empty, cannot refresh access token")
            DispatchQueue.main.async {
                self.errorMessage = "Session expired. Please log in again."
                self.showError = true
                self.logout()
            }
            completion(false)
            return
        }

        if isRefreshTokenExpired() {
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

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_REFRESH) { responseObj in
            self.isRefreshingToken = false
            if let response = responseObj as? NSDictionary {
                if let newAccessToken = response["accessToken"] as? String {
                    print("New access token received: \(newAccessToken)")
                    DispatchQueue.main.async {
                        self.token = newAccessToken
                        // Giải mã token mới để lấy thời gian hết hạn
                        // Giải mã token mới để lấy thời gian hết hạn
                        do {
                            let jwt = try decode(jwt: newAccessToken)
                            let expClaim = jwt.claim(name: "exp")
                            if let exp = expClaim.double {
                                self.tokenExpirationDate = Date(timeIntervalSince1970: exp)
                                print("New token expiration date: \(String(describing: self.tokenExpirationDate))")
                            } else {
                                // Nếu không lấy được exp, sử dụng giá trị mặc định từ expiresIn
                                let expiresIn = response["expiresIn"] as? Int ?? 3600
                                self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                                print("New token expiration date (default): \(String(describing: self.tokenExpirationDate))")
                            }
                        } catch {
                            print("Failed to decode new access token: \(error)")
                            let expiresIn = response["expiresIn"] as? Int ?? 3600
                            self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                            print("New token expiration date (default): \(String(describing: self.tokenExpirationDate))")
                        }
                        if let userDict = Utils.UDValue(key: Globs.userPayload) as? NSMutableDictionary {
                            userDict["token"] = self.token
                            Utils.UDSET(data: userDict, key: Globs.userPayload)
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

    /// Gọi API với kiểm tra token
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    public func callApiWithTokenCheck(method: HTTPMethod, path: String, parameters: NSDictionary, withSuccess: @escaping (Any?) -> Void, failure: @escaping (Error?) -> Void) {
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

    /// Thực hiện gọi API dựa trên phương thức HTTP
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
        DispatchQueue.main.async(execute: {
            self.clearSession()
            self.navigateToLogin = true
        })
    }
        
    // Delete session/tempToken
    func clearSession() {
        self.token = ""
        self.refreshToken = ""
        self.isUserLogin = false
        
        self.userObj = UserModel(dict: [:])
        self.navigateTo = false
        self.navigateToLogin = false
        
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
        
        Utils.UDSET(data: false, key: Globs.userLogin)
        Utils.UDSET(data: [:], key: Globs.userPayload)
    }

    // MARK: - Set User Data
    func setUserData(uDict: NSDictionary) {
        Utils.UDSET(data: uDict, key: Globs.userPayload)
        Utils.UDSET(data: true, key: Globs.userLogin)
        
        DispatchQueue.main.async {
            self.userObj = UserModel(dict: uDict)
            self.isUserLogin = true
            self.token = uDict["token"] as? String ?? ""
            self.refreshToken = uDict["refreshToken"] as? String ?? ""
            
            self.userRole = uDict["role"] as? String ?? ""
            
            self.txtFullName = ""
            self.txtEmail = ""
            self.txtPassword = ""
            self.txtPhone = ""
            self.txtAddress = ""
            self.isShowPassword = false
        }
    }
    
    func setUser(uDict: NSDictionary) {
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
