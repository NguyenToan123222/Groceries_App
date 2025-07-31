//
//  AdminAccountDetailViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 24/4/25.
//

import SwiftUI

class AdminAccountDetailViewModel: ObservableObject {
    @Published var user: UserModel
    @Published var showError = false
    @Published var errorMessage = ""

    init(userId: Int) {
        // Initialize with a placeholder user, will be updated after fetching
        self.user = UserModel(dict: [:])
        fetchUserDetails(userId: userId)
    }

    func fetchUserDetails(userId: Int) {
        let path = "\(Globs.BASE_URL)users/\(userId)"
        
        MainViewModel.shared.callApiWithTokenCheck(
            method: .get,
            path: path,
            parameters: [:],
            withSuccess: { responseObj in
                Task { @MainActor in
                    if let response = responseObj as? NSDictionary {
                        self.user = UserModel(dict: response)
                    } else {
                        self.errorMessage = "Failed to fetch user details"
                        self.showError = true
                    }
                }
            },
            failure: { error in
                Task { @MainActor in
                    self.errorMessage = error?.localizedDescription ?? "Network error: Failed to fetch user details"
                    self.showError = true
                }
            }
        )
    }
}
