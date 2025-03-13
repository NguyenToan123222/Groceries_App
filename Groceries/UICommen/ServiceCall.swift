import SwiftUI
import UIKit

class ServiceCall {
    class func post(
        parameter: NSDictionary,
        path: String,
        withSuccess: @escaping ((_ responseObj: AnyObject?) -> ()),
        failure: @escaping ((_ error: Error?) -> ())
    ) {
        DispatchQueue.global(qos: .userInitiated).async { // chạy trên luồng nền
            // Chuyển parameter thành dữ liệu JSON
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameter, options: [])
                /*
                 ✅ DÙNG "try" để throw ra lỗi. NẾU CHUYỂN JSON KHÔNG THÀNH CÔNG
                 - Chuyển parameter (NSDictionary) thành JSON (Data) để gửi lên server.
                 - Nếu lỗi, chạy failure(error) trên main thread và dừng hàm.
                 */
            } catch {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }

            // Tạo request
            var request = URLRequest(url: URL(string: path)!, timeoutInterval: 20) // "!" CHẮC CHẮN HỢP LỆ
            request.httpMethod = "POST"
            
           /*
            ✅
            var request = URLRequest (url: URL(string: path)!, timeoutInterval: 20)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if (isToken) {
                #if DEBUG
                request.addValue(MainViewModel.shared.userObj.authToken, forHTTPHeaderField: "access_token")
                #else
                request.addValue(MainViewModel.shared.userObj.authToken, forHTTPHeaderField: "access_token")
                #endif
            }
            request.httpMethod = "POST"
            request.httpBody = parameterData as Data
            */
            
            // Đặt Content-Type là application/json
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Gắn dữ liệu JSON vào body
            request.httpBody = jsonData
            
            // Debug thông tin request
            debugPrint("Request URL: \(path)")
            debugPrint("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid data")")

            // Gửi request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                    return
                }
                /*
                 KIỂM TRA:
                 - data có dữ liệu thì gán vào data
                 - nếu không thì áo lỗi, rồi return (thoát)
                 */
                guard let data = data else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    }
                    return
                }

                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    // Chuyển data từ server thành NSDictionary
                    debugPrint("Response: ", jsonDictionary ?? "No response")
                    DispatchQueue.main.async {
                        withSuccess(jsonDictionary)
                    }
                } catch {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            }
            
            task.resume()
        }
    }
}
