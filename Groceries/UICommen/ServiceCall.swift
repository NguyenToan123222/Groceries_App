import SwiftUI
import UIKit

class ServiceCall {
    class func post(
        parameter: NSDictionary,
        path: String,
        withSuccess: @escaping ((_ responseObj: AnyObject?) -> ()),
        failure: @escaping ((_ error: Error?) -> ())
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameter, options: [])
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

                if httpResponse.statusCode == 401 {
                    // Token hết hạn, làm mới token
                    MainViewModel.shared.refreshAccessToken { success in
                        if success {
                            // Gọi lại API với token mới
                            var newRequest = request
                            newRequest.setValue("Bearer \(MainViewModel.shared.token)", forHTTPHeaderField: "Authorization")
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
                    DispatchQueue.main.async {
                        failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
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

            task.resume()
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
