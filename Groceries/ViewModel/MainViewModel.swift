import SwiftUI

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
    // Dùng để tạo lại một token mới khi token cũ hết hạn, mà không cần đăng nhập lại.
    
    
    @Published var showSuccess = false // Thêm biến để hiển thị thông báo thành công
    @Published var successMessage = "" // Thông báo thành công
    @Published var navigateTo = false // Thêm biến để kích hoạt điều hướng
    
    
    // reset password
    @Published var otpCode: String = ""
    @Published var navigateToLogin = false
    
    // change password
    @Published var txtOldPassword: String = "" // old pass
  
    
    // Thời gian hết hạn của accessToken
    private var tokenExpirationDate: Date? {
            get { Utils.UDValue(key: "tokenExpirationDate") as? Date }
            set { Utils.UDSET(data: newValue, key: "tokenExpirationDate") }
        }
    
    
    init () {
        // Hàm này kiểm tra xem Globs.userLogin có giá trị true hay không trong UserDefaults.
        if Utils.UDValueBool(key: Globs.userLogin) {
                    let userDict = Utils.UDValue(key: Globs.userPayload) as? NSDictionary ?? [:]
                    // UserDefaults chứa thông tin người dùng
                    self.setUserData(uDict: userDict) // cập nhật thông tin cho setUserData
                    
                }

        else {
            // User not Login
        }
        
        
//               #if DEBUG
//                txtUsername = "user4"
//                txtEmail = "test6@gmail.com"
//                txtPassword = "123456"
//                #endif
    }

      
//        #if DEBUG
//        txtUsername = "user4"
//        txtEmail = "test@gmail.com"
//        txtPassword = "123456"
//        #endif
//        
//    }
//    

    

//MARK: Log In
    func serviceCallLogin() {
        if txtEmail.isEmpty {
            self.errorMessage = "Please enter a valid email address"
            self.showError = true
            return
        }
        
        if txtPassword.isEmpty {
            self.errorMessage = "Please enter a valid password"
            self.showError = true
            return
        }
        
        let parameters = ["email": txtEmail, "password": txtPassword]
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_LOGIN) { responseObj in
            
            if let response = responseObj as? NSDictionary {
                // Backend không trả về "status", nên kiểm tra "message" thay vì "status"
                if response["message"] as? String == "Login successful" {
                    // Lấy token, refreshToken và user từ response
                    self.token = response["token"] as? String ?? ""
                    self.refreshToken = response["refreshToken"] as? String ?? ""
                    
                    let userDict = response["user"] as? NSDictionary ?? [:]
                    
                    // Lưu dữ liệu vào UserDefaults và cập nhật trạng thái
                    var payloadDict = userDict.mutableCopy() as! NSMutableDictionary
                    //Tạo một bản sao của userDict dưới dạng NSMutableDictionary, cho phép chỉnh sửa dữ liệu.
                    payloadDict["token"] = self.token
                    payloadDict["refreshToken"] = self.refreshToken
                    // lưu trữ cho các lần tiếp theo
                    
                    self.setUserData(uDict: payloadDict) // lưu thong tin người dùng
                    
                    self.navigateTo = true
                    self.navigateToLogin = false // Đảm bảo không quay lại LoginView ngay lập tức
                } else {
                    // Lấy lỗi từ "error" nếu có trong phản hồi lỗi từ backend
                    self.errorMessage = response["error"] as? String ?? "Login failed"
                    self.showError = true
                }
            }
        }
        failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }
    // MARK: - Sign Up

    func serviceCallSignUp() {
        if txtFullName.isEmpty {
            self.errorMessage = "Please enter your full name"
            self.showError = true
            return
        }

        if !txtEmail.isValidEmail {
            self.errorMessage = "Please enter a valid email address"
            self.showError = true
            return
        }

        if txtPassword.isEmpty {
            self.errorMessage = "Please enter a valid password"
            self.showError = true
            return
        }

        if txtPhone.isEmpty {
            self.errorMessage = "Please enter your phone number"
            self.showError = true
            return
        }

        if txtAddress.isEmpty {
            self.errorMessage = "Please enter your address"
            self.showError = true
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

                    // Lưu userDict vào UserDefaults (bộ nhớ cục bộ của ứng dụng) với key là Globs.userPayload. để sử dụng lại mà không cần gọi API mỗi lần.
                    Utils.UDSET(data: userDict, key: Globs.userPayload) // Lưu lâu dài để dùng lại sau khi tắt app
                    self.userObj = UserModel(dict: userDict) // Cập nhật trạng thái hiện tại cho UI

                    self.successMessage = "Registration successful! Please verify your email"
                    self.showSuccess = true
                    self.navigateTo = true // Điều hướng sang OTPView
                } else {
                    self.errorMessage = response["error"] as? String ?? "Registration failed"
                    self.showError = true
                }
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }
    // MARK: - Send OTP

    func serviceCallSendOTP() {
        let parameters = ["email": txtEmail]

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_SEND_OTP) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "OTP has been sent" {
                    self.token = response["tempToken"] as? String ?? ""
                    self.successMessage = "OTP sent successfully"
                    self.showSuccess = true
                } else {
                    self.errorMessage = response["error"] as? String ?? "Failed to send OTP"
                    self.showError = true
                }
            }
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Network error"
            self.showError = true
        }
    }
    // MARK: - Reset Password

    
            
//            let parameters = [
//                "tempToken": token,      // Lấy từ mainVM.token
//                "otp": otpCode,          // Lấy từ mainVM.otpCode
//                "newPassword": txtPassword // Lấy từ mainVM.txtPassword
//            ]
            
        /*
         self.token = response["tempToken"] as? String ?? "" (temToken)
         @Published var otpCode: String = "" của MainViewModel. -> mainVM.otpCode (otp)
         @Published var txtPassword: String = "" của MainViewModel. -> mainVM.txtPassword. (password)
         
         Khi nhấn "Reset Password", hàm serviceCallResetPassword() lấy các giá trị từ mainVM.token, mainVM.otpCode, và mainVM.txtPassword để gửi lên API /reset-password.
         */
            
    func serviceCallResetPassword() {
        if txtEmail.isEmpty {
            self.errorMessage = "Please enter your email"
            self.showError = true
            return
        }
        
        if otpCode.isEmpty {
            self.errorMessage = "Please enter the OTP"
            self.showError = true
            return
        }
        
        if txtPassword.isEmpty {
            self.errorMessage = "Please enter a new password"
            self.showError = true
            return
        }
        
        // Prepare the request body as JSON
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
                        self.clearSession()
                        self.successMessage = "Your password has updated. Please log in again!"
                        self.showSuccess = true
                        self.navigateToLogin = true
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
        // Ensure userObj.email is not empty
        guard !userObj.email.isEmpty else {
            self.errorMessage = "User email not found. Please log in again."
            self.showError = true
            self.logout()
            return
        }
        
        if txtOldPassword.isEmpty {
            self.errorMessage = "Please enter your old password"
            self.showError = true
            return
        }
        
        if txtPassword.isEmpty {
            self.errorMessage = "Please enter a new password"
            self.showError = true
            return
        }
        
        // Prepare the parameters
        let parameters = [
            "email": self.userObj.email,
            "oldPassword": txtOldPassword,
            "newPassword": txtPassword
        ]
        
        // Since the backend expects query parameters (@RequestParam), construct the URL with query items
        var components = URLComponents(string: Globs.SV_CHANGE_PASSWORD)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            self.showError = true
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
                    
                    // Đăng xuất sau khi đổi mật khẩu thành công
                    self.logout()
                    self.navigateToLogin = true // Điều hướng về LoginView
                } else {
                    self.errorMessage = responseString
                    self.showError = true
                }
            }
        }.resume()
    }
        
    // MARK: - Token Management
        
        private func isTokenExpired() -> Bool {
            guard !token.isEmpty, let expirationDate = tokenExpirationDate else {
                return true
            }
            return Date() >= expirationDate
        }
        
        func refreshAccessToken(completion: @escaping (Bool) -> Void) {
            let parameters = ["refreshToken": refreshToken]
            
            ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_REFRESH) { responseObj in
                if let response = responseObj as? NSDictionary {
                    if let newAccessToken = response["accessToken"] as? String {
                        self.token = newAccessToken
                        let expiresIn = response["expiresIn"] as? Int ?? 3600
                        self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                        
                        if let userDict = Utils.UDValue(key: Globs.userPayload) as? NSMutableDictionary {
                            userDict["token"] = self.token
                            Utils.UDSET(data: userDict, key: Globs.userPayload)
                        }
                        completion(true)
                    } else {
                        self.errorMessage = "Failed to refresh token"
                        self.showError = true
                        self.logout()
                        completion(false)
                    }
                }
            } failure: { error in
                self.errorMessage = error?.localizedDescription ?? "Network error"
                self.showError = true
                self.logout()
                completion(false)
            }
        }
        
        private func callApiWithTokenCheck(path: String, parameters: NSDictionary, withSuccess: @escaping (Any?) -> Void, failure: @escaping (Error?) -> Void) {
            if isTokenExpired() && !refreshToken.isEmpty {
                refreshAccessToken { success in
                    if success {
                        // Gọi API với token mới, không truyền token trực tiếp nếu ServiceCall không hỗ trợ
                        ServiceCall.post(parameter: parameters, path: path) { responseObj in
                            withSuccess(responseObj)
                        } failure: { error in
                            failure(error)
                        }
                    } else {
                        failure(nil)
                    }
                }
            } else if token.isEmpty {
                self.errorMessage = "Session expired. Please log in again."
                self.showError = true
                self.logout()
                failure(nil)
            } else {
                ServiceCall.post(parameter: parameters, path: path) { responseObj in
                    withSuccess(responseObj)
                } failure: { error in
                    failure(error)
                }
            }
        }
    // Logout
    func logout() {
        self.clearSession() // Xóa session
        self.navigateToLogin = true // Điều hướng về LoginView
    }
        
    // Delete session/tempToken
    func clearSession() {
        self.token = "" // Xóa tempToken
        self.refreshToken = ""
        self.isUserLogin = false
        Utils.UDSET(data: false, key: Globs.userLogin)
        Utils.UDSET(data: [:], key: Globs.userPayload)
    }

// MARK: - Set User Data
    
    func setUserData(uDict: NSDictionary) {
        Utils.UDSET(data: uDict, key: Globs.userPayload)
        Utils.UDSET(data: true, key: Globs.userLogin)
        
        self.userObj = UserModel(dict: uDict)
        self.isUserLogin = true
        self.token = uDict["token"] as? String ?? ""
        self.refreshToken = uDict["refreshToken"] as? String ?? ""
        
        // Reset fields sau khi đăng nhập thành công
        self.txtFullName = ""
        self.txtEmail = ""
        self.txtPassword = ""
        self.txtPhone = ""
        self.txtAddress = ""
        self.isShowPassword = false    }
    
    func setUser(uDict: NSDictionary) {
        Utils.UDSET(data: uDict, key: Globs.userPayload)
        Utils.UDSET(data: true, key: Globs.userLogin)

        self.userObj = UserModel(dict: uDict)
        self.isUserLogin = true
        
        self.txtFullName = ""
        self.txtEmail = ""
        self.txtPassword = ""
        self.isShowPassword = false
    }
}
