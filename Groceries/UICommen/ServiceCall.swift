import SwiftUI
import UIKit

class ServiceCall {
    class func post(
        parameter: NSDictionary,
        path: String,
        withSuccess: @escaping ((_ responseObj: AnyObject?) -> ()),
        failure: @escaping ((_ error: Error?) -> ())
    ) {
        /*
         ServiceCall.post(
           parameter: ["username": "user", "password": "pass"],
           path: "https://api.example.com/login",
           withSuccess: { response in print("Đăng nhập thành công: \(response)") },
           failure: { error in print("Lỗi: \(error?.localizedDescription ?? "Unknown")") }
         )
         */
        DispatchQueue.global(qos: .userInitiated).async { // background Thread
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameter, options: []) // convert parameter Json
            } catch {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }

            var request = URLRequest(url: URL(string: path)!, timeoutInterval: 20)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if !MainViewModel.shared.token.isEmpty {
                request.addValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
            }

            request.httpBody = jsonData

            debugPrint("Request URL: \(path)")
            debugPrint("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid data")")
            debugPrint("Authorization Header: \(request.value(forHTTPHeaderField: "Authorization") ?? "No token")")
            /*
             Request URL: https://api.example.com/login
             Request Body: {"username":"user","password":"pass"}
             Authorization Header: Bearer abc123
             */

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                    return
                }

                if httpResponse.statusCode == 401 { // token hết hạn hoặc không hợp lệ
                    MainViewModel.shared.refreshAccessToken { success in
                        if success { // Nếu làm mới token thành công (success == true):
                            var newRequest = request // Tạo newRequest từ request gốc.
                            newRequest.setValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
                            // Cập nhật header Authorization với token mới từ MainViewModel.shared.token.
                            URLSession.shared.dataTask(with: newRequest) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        failure(error)
                                    }
                                    return
                                }

                                guard let data = data else {
                                    DispatchQueue.main.async {
                                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                                    }
                                    return
                                }

                                /*
                                 Chuyển data thành chuỗi UTF-8.
                                 Nếu chuỗi không bắt đầu bằng { hoặc [ (không phải JSON), gọi withSuccess với chuỗi.
                                 Ví dụ: Server trả về "Order created" → Gọi withSuccess("Order created").
                                 */
                                if let stringResponse = String(data: data, encoding: .utf8), !stringResponse.hasPrefix("{") && !stringResponse.hasPrefix("[") {
                                    DispatchQueue.main.async {
                                        withSuccess(stringResponse as AnyObject)
                                    }
                                    return
                                }

                                do {
                                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary // Chuyển data thành JSON (NSDictionary)
                                    debugPrint("Response: ", jsonDictionary ?? "No response")
                                    DispatchQueue.main.async {
                                        withSuccess(jsonDictionary) // {"orderId": 456} → Gọi withSuccess(["orderId": 456]).
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        failure(error)
                                    }
                                }
                            }.resume() // dataTask
                        } else {
                            DispatchQueue.main.async {
                                failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"]))
                            }
                        }
                    }
                    return
                } // if 401

                guard let data = data else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    }
                    return
                }

                // Kiểm tra nếu phản hồi là chuỗi văn bản
                if let stringResponse = String(data: data, encoding: .utf8), !stringResponse.hasPrefix("{") && !stringResponse.hasPrefix("[") {
                    DispatchQueue.main.async {
                        withSuccess(stringResponse as AnyObject)
                    }
                    return
                }

                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
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

            task.resume() // Gửi yêu cầu HTTP ban đầu
        }
    }

class func get(path: String, withSuccess: @escaping ((Any?) -> ()), failure: @escaping ((Error?) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            var request = URLRequest(url: URL(string: path)!, timeoutInterval: 20)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if !MainViewModel.shared.token.isEmpty {
                request.addValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async { failure(error) }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                    return
                }

                if httpResponse.statusCode == 401 {
                    MainViewModel.shared.refreshAccessToken { success in
                        if success {
                            var newRequest = request
                            newRequest.setValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
                            URLSession.shared.dataTask(with: newRequest) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async { failure(error) }
                                    return
                                }

                                guard let data = data else {
                                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                                    return
                                }

                                do {
                                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                    if jsonObject is NSDictionary || jsonObject is NSArray {
                                        DispatchQueue.main.async { withSuccess(jsonObject) }
                                    } else {
                                        DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])) }
                                    }
                                } catch {
                                    DispatchQueue.main.async { failure(error) }
                                }
                            }.resume()
                        } else {
                            DispatchQueue.main.async {
                                failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"]))
                            }
                        }
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                    return
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if jsonObject is NSDictionary || jsonObject is NSArray {
                        DispatchQueue.main.async { withSuccess(jsonObject) }
                    } else {
                        DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])) }
                    }
                } catch {
                    DispatchQueue.main.async { failure(error) }
                }
            }
            task.resume()
        }
    }

    class func put(parameter: NSDictionary, path: String, withSuccess: @escaping ((AnyObject?) -> ()), failure: @escaping ((Error?) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameter, options: [])
            } catch {
                DispatchQueue.main.async { failure(error) }
                return
            }

            var request = URLRequest(url: URL(string: path)!, timeoutInterval: 20)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if !MainViewModel.shared.token.isEmpty {
                request.addValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
            }

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async { failure(error) }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                    return
                }

                if httpResponse.statusCode == 401 {
                    MainViewModel.shared.refreshAccessToken { success in
                        if success {
                            var newRequest = request
                            newRequest.setValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
                            URLSession.shared.dataTask(with: newRequest) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async { failure(error) }
                                    return
                                }

                                guard let data = data else {
                                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                                    return
                                }

                                do {
                                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                                    DispatchQueue.main.async { withSuccess(jsonDictionary) }
                                } catch {
                                    DispatchQueue.main.async { failure(error) }
                                }
                            }.resume()
                        } else {
                            DispatchQueue.main.async {
                                failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"]))
                            }
                        }
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                    return
                }

                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    DispatchQueue.main.async { withSuccess(jsonDictionary) }
                } catch {
                    DispatchQueue.main.async { failure(error) }
                }
            }
            task.resume()
        }
    }

    class func delete(path: String, withSuccess: @escaping ((AnyObject?) -> ()), failure: @escaping ((Error?) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            var request = URLRequest(url: URL(string: path)!, timeoutInterval: 20)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if !MainViewModel.shared.token.isEmpty {
                request.addValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async { failure(error) }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    }
                    return
                }

                if httpResponse.statusCode == 401 {
                    MainViewModel.shared.refreshAccessToken { success in
                        if success {
                            var newRequest = request
                            newRequest.setValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
                            URLSession.shared.dataTask(with: newRequest) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async { failure(error) }
                                    return
                                }

                                guard let data = data else {
                                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                                    return
                                }

                                do {
                                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                                    DispatchQueue.main.async { withSuccess(jsonDictionary) }
                                } catch {
                                    DispatchQueue.main.async { failure(error) }
                                }
                            }.resume()
                        } else {
                            DispatchQueue.main.async {
                                failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"]))
                            }
                        }
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async { failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])) }
                    return
                }

                do {
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    DispatchQueue.main.async { withSuccess(jsonDictionary) }
                } catch {
                    DispatchQueue.main.async { failure(error) }
                }
            }
            task.resume()
        }
    }
}
