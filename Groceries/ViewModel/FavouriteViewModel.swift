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
            withSuccess: { [weak self] responseObj in
                guard let self = self else { return }
                print("Favorites API Response: \(String(describing: responseObj))")
                if let favoritesArray = responseObj as? NSArray {
                    DispatchQueue.main.async {
                        self.listArr = favoritesArray.compactMap { obj in
                            guard let dict = obj as? NSDictionary else {
                                print("Failed to parse object as NSDictionary: \(obj)")
                                return nil
                            }
                            return ProductModel(dict: dict)
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
        
        let path = Globs.SV_ADD_FAVORITE.replacingOccurrences(of: "{productId}", with: "\(productId)")
        MainViewModel.shared.callApiWithTokenCheck(
            method: .post,
            path: path,
            parameters: [:],
            withSuccess: { [weak self] responseObj in
                guard let self = self else { return }
                print("Add Favorite API Response: \(String(describing: responseObj))")
                
                if let message = responseObj as? String {
                    let success = message.lowercased().contains("added")
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
                            let isAdded = self.listArr.contains { $0.id == productId }
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
                            let isRemoved = !self.listArr.contains { $0.id == productId }
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
                        let isRemoved = !self.listArr.contains { $0.id == productId }
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
