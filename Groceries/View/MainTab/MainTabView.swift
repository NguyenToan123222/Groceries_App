//
//  MainTabView.swift
//  OnlineGroceriesSwiftUI
//
//  Created by CodeForAny on 02/08/23.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var homeVM = HomeViewModel.shared
    @State private var animateTabBar = false // Biến để điều khiển animation của tab bar
    @State private var animateGradient = false // Biến để điều khiển animation của gradient
    
    @FocusState private var isFocused: Bool
        
    func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.dismissKeyboardGlobally()
    }
    
    var body: some View {
        ZStack {
            // Background loang màu xanh lam nhạt
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.cyan.opacity(0.4),
                    Color.white.opacity(0.3),
                    Color.blue.opacity(0.3)
                ]),
                center: .center,
                startRadius: animateGradient ? 50 : 100,
                endRadius: animateGradient ? 500 : 300
            )
            .edgesIgnoringSafeArea(.all)
            .hueRotation(.degrees(animateGradient ? 0 : 45)) // Tạo hiệu ứng chuyển động màu
            .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            // Nội dung chính
            if (homeVM.selectTab == 0) {
                HomeView()
            } else if (homeVM.selectTab == 1) {
                ExploreView()
            } else if (homeVM.selectTab == 2) {
                MyCartView()
            } else if (homeVM.selectTab == 3) {
                FavouriteView()
            } else if (homeVM.selectTab == 4) {
                NavigationView {
                    AccountView()
                }
            }
            
            // Tab bar
            VStack {
                Spacer()
                
                HStack {
                    TabButton(title: "Shop", icon: "home_tab", isSelect: homeVM.selectTab == 0) {
                        print("Button Tab")
                        withAnimation(.spring()) {
                            homeVM.selectTab = 0
                        }
                    }
                    .scaleEffect(homeVM.selectTab == 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: homeVM.selectTab)
                    
                    TabButton(title: "Explore", icon: "explore_tab1", isSelect: homeVM.selectTab == 1) {
                        withAnimation(.spring()) {
                            homeVM.selectTab = 1
                        }
                    }
                    .scaleEffect(homeVM.selectTab == 1 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: homeVM.selectTab)
                    
                    TabButton(title: "Cart", icon: "cart_tab1", isSelect: homeVM.selectTab == 2) {
                        withAnimation(.spring()) {
                            homeVM.selectTab = 2
                        }
                    }
                    .scaleEffect(homeVM.selectTab == 2 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: homeVM.selectTab)
                    
                    TabButton(title: "Favourite", icon: "fav_tab1", isSelect: homeVM.selectTab == 3) {
                        withAnimation(.spring()) {
                            homeVM.selectTab = 3
                        }
                    }
                    .scaleEffect(homeVM.selectTab == 3 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: homeVM.selectTab)
                    
                    TabButton(title: "Account", icon: "account_tab1", isSelect: homeVM.selectTab == 4) {
                        withAnimation(.spring()) {
                            homeVM.selectTab = 4
                        }
                    }
                    .scaleEffect(homeVM.selectTab == 4 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: homeVM.selectTab)
                }
                .padding(.top, 10)
                .padding(.bottom, .bottomInsets)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: -2)
                .scaleEffect(animateTabBar ? 1.0 : 0.8)
                .opacity(animateTabBar ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: animateTabBar)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onAppear {
            animateTabBar = true
            animateGradient = true // Kích hoạt animation cho gradient
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainTabView()
        }
    }
}
