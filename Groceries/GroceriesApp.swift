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

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !hasLaunchedBefore { // là false (tức là ứng dụng chạy lần đầu tiên)
                    WelcomeView()
                        .environmentObject(mainVM) // Truyền MainViewModel vào môi trường
                        .onAppear {
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            hasLaunchedBefore = true //đảm bảo rằng lần chạy tiếp theo của ứng dụng= true
                        }
                } else { // là true (ứng dụng đã chạy trước đó)
                    if mainVM.isUserLogin { // người dùng đã đăng nhập hay chưa.
                        if mainVM.isAdmin() { // admin
                            AdminView()
                                .environmentObject(mainVM)
                        } else { //  customer
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
                // Đóng bàn phím toàn cục khi ứng dụng khởi động
                UIApplication.shared.dismissKeyboardGlobally()
            }
            
        }
    }
}
// ✅  Naviagtion View chồng lên nhau ở nhiều View sẽ bị: "hiển thị nút BACK mặc định"
