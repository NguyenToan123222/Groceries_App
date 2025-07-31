//
//  FavouriteViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 14/3/25.
//

import SwiftUI

class FavouriteViewModel: ObservableObject {
    static let shared = FavouriteViewModel()
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var listArr: [ProductModel] = []
    
    private init() {
        if MainViewModel.shared.isUserLogin {
            serviceCallDetail()
        } else {
            self.errorMessage = "Please log in to view your favorites"
            self.showError = true
            MainViewModel.shared.logout()
        }
    }
    
    func serviceCallDetail(completion: (() -> Void)? = nil) {
        print("Calling serviceCallDetail to fetch favorites...")
        MainViewModel.shared.callApiWithTokenCheck(
            method: .get,
            path: Globs.SV_FAVORITE_LIST,
            parameters: [:],
            withSuccess: { [weak self] responseObj in // giữ self nhẹ, có thể bị xóa nếu không cần
                guard let self = self else { return }
                print("Favorites API Response: \(String(describing: responseObj))")
                if let favoritesArray = responseObj as? NSArray {
                    DispatchQueue.main.async {
                        self.listArr = favoritesArray.compactMap { obj in // list Product Model
                            guard let dict = obj as? NSDictionary
                            else {
                                print("Failed to parse object as NSDictionary: \(obj)")
                                return nil
                            }
                            return ProductModel(dict: dict)
                            /*
                             Bước 1: Duyệt từng obj trong favoritesArray.
                             Bước 2: Thử ép obj thành NSDictionary.
                               - Nếu thất bại, trả nil (bỏ qua phần tử).
                               - Nếu thành công, tạo ProductModel từ dict.
                             Bước 3: Thu thập các ProductModel (bỏ qua nil) thành mảng [ProductModel].
                               - compactMap thu thập: [ProductModel(id: 456, name: "Táo"), ProductModel(id: 459, name: "Dứa")].
                             Bước 4: Gán mảng vào listArr.
                             */
                        }
                        print("Favorites list updated: \(self.listArr)")
                        completion?()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Unexpected response format"
                        self.showError = true
                        print("Favorites API failed with message: \(self.errorMessage)")
                        completion?()
                    }
                }
            },
            failure: { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Failed to fetch favorites"
                    self.showError = true
                    print("Favorites API error: \(self.errorMessage)")
                    completion?()
                }
            }
        )
    }
    
    func addFavorite(productId: Int, completion: @escaping (Bool, String) -> Void = { _, _ in }) {
        guard MainViewModel.shared.isUserLogin else {
            DispatchQueue.main.async {
                self.errorMessage = "Please log in to add to favorites"
                self.showError = true
                MainViewModel.shared.logout()
                completion(false, self.errorMessage)
            }
            return
        }
        // /api/favorites/add/{productId}) :  (như /api/favorites/add/456).
        let path = Globs.SV_ADD_FAVORITE.replacingOccurrences(of: "{productId}", with: "\(productId)")
        MainViewModel.shared.callApiWithTokenCheck(
            method: .post,
            path: path,
            parameters: [:],
            withSuccess: { [weak self] responseObj in
                guard let self = self else { return }
                print("Add Favorite API Response: \(String(describing: responseObj))")
                
                if let message = responseObj as? String { // string
                    let success = message.lowercased().contains("added")
                    if success {
                        self.serviceCallDetail { // lấy danh sách yêu thích mới
                            completion(true, message)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = message
                            self.showError = true
                            completion(false, message)
                        }
                    }
                } else if let dict = responseObj as? [String: Any], let message = dict["message"] as? String { // faults
                    // dictionary: ["message": "Product already exists"]
                    DispatchQueue.main.async {
                        self.errorMessage = message
                        self.showError = true
                        completion(false, message)
                    }
                } else { // another undefine || check list agian
                    self.serviceCallDetail {
                        DispatchQueue.main.async {
                            let isAdded = self.listArr.contains { $0.id == productId }
                            /*
                             Kiểm tra xem listArr có ProductModel với id bằng productId không.
                             $0: Đại diện cho "mỗi" ProductModel trong listArr.
                             */
                            if isAdded {
                                completion(true, "Added to favorites.")
                            } else {
                                self.errorMessage = "Unexpected response format"
                                self.showError = true
                                completion(false, self.errorMessage)
                            }
                        }
                    }
                }
            },
            failure: { [weak self] error in
                guard let self = self else { return }
                self.serviceCallDetail {
                    DispatchQueue.main.async {
                        let isAdded = self.listArr.contains { $0.id == productId }
                        if isAdded {
                            completion(true, "Added to favorites.")
                        } else {
                            self.errorMessage = error?.localizedDescription ?? "Failed to add to favorites"
                            self.showError = true
                            completion(false, self.errorMessage)
                        }
                    }
                }
            }
        )
    }
    
    func removeFavorite(productId: Int, completion: @escaping (Bool, String) -> Void = { _, _ in }) {
        guard MainViewModel.shared.isUserLogin else {
            DispatchQueue.main.async {
                self.errorMessage = "Please log in to remove from favorites"
                self.showError = true
                MainViewModel.shared.logout()
                completion(false, self.errorMessage)
            }
            return
        }
        
        let path = Globs.SV_REMOVE_FAVORITE.replacingOccurrences(of: "{productId}", with: "\(productId)")
        MainViewModel.shared.callApiWithTokenCheck(
            method: .delete,
            path: path,
            parameters: [:],
            withSuccess: { [weak self] responseObj in
                guard let self = self else { return }
                print("Remove Favorite API Response: \(String(describing: responseObj))")
                
                if let message = responseObj as? String {
                    let success = message.lowercased().contains("removed")
                    if success {
                        self.serviceCallDetail {
                            completion(true, message)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = message
                            self.showError = true
                            completion(false, message)
                        }
                    }
                } else if let dict = responseObj as? [String: Any], let message = dict["message"] as? String {
                    DispatchQueue.main.async {
                        self.errorMessage = message
                        self.showError = true
                        completion(false, message)
                    }
                } else {
                    self.serviceCallDetail {
                        DispatchQueue.main.async {
                            let isRemoved = !self.listArr.contains { $0.id == productId } // Kiểm tra sản phẩm không có trong listArr (nghĩa là đã xóa).
                            if isRemoved {
                                completion(true, "Removed from favorites.")
                            } else {
                                self.errorMessage = "Unexpected response format"
                                self.showError = true
                                completion(false, self.errorMessage)
                            }
                        }
                    }
                }
            },
            failure: { [weak self] error in
                guard let self = self else { return }
                self.serviceCallDetail {
                    DispatchQueue.main.async {
                        let isRemoved = !self.listArr.contains { $0.id == productId } // Kiểm tra sản phẩm không có trong listArr (nghĩa là đã xóa).
                        if isRemoved {
                            completion(true, "Removed from favorites.")
                        } else {
                            self.errorMessage = error?.localizedDescription ?? "Failed to remove from favorites"
                            self.showError = true
                            completion(false, self.errorMessage)
                        }
                    }
                }
            }
        )
    }
}
