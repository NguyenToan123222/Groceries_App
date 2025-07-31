//
//  GroceriesApp.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 14/3/25.
//

import SwiftUI

@main
struct GroceriesApp: App {
    @StateObject var mainVM = MainViewModel.shared
    @State private var hasLaunchedBefore: Bool = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                if !hasLaunchedBefore {
                    WelcomeView()
                        .environmentObject(mainVM)
                        .onAppear {
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            hasLaunchedBefore = true
                        }
                } else {
                    if mainVM.isUserLogin {
                        if mainVM.isAdmin() {
                            AdminView()
                                .environmentObject(mainVM)
                        } else {
                            MainTabView()
                                .environmentObject(mainVM)
                        }
                    } else {
                        LoginView()
                            .environmentObject(mainVM)
                    }
                }
            }
            .onAppear {
                UIApplication.shared.dismissKeyboardGlobally()
            }
            .onChange(of: mainVM.navigateToLogin) { newValue in
                if newValue {
                    navigationPath = NavigationPath() // Làm sạch stack
                    mainVM.navigateToLogin = false // Reset trạng thái sau khi điều hướng
                }
            }
        }
    }
}
// ✅  Naviagtion View chồng lên nhau ở nhiều View sẽ bị: "hiển thị nút BACK mặc định"
