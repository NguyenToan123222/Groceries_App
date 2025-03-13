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
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
            }
        }
    }
}

// ✅  Naviagtion View chồng lên nhau ở nhiều View sẽ bị: "hiển thị nút BACK mặc định"
