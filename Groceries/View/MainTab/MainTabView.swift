//
//  MainTabView.swift
//  OnlineGroceriesSwiftUI
//
//  Created by CodeForAny on 02/08/23.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @StateObject var homeVM = HomeViewModel.shared
    @State private var animateTabBar = false
    @State private var animateGradient = false
    
    @FocusState private var isFocused
        
    func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.dismissKeyboardGlobally()
    }
    
    var body: some View {
        ZStack {
            RadialGradient( // unnecessary

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
            .hueRotation(.degrees(animateGradient ? 0 : 45))
            .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            // Nội dung chính
            if (homeVM.selectTab == 0) {
                HomeView()
                    .environmentObject(mainVM)
            } else if (homeVM.selectTab == 1) {
                ExploreView()
                    .environmentObject(mainVM)
            } else if (homeVM.selectTab == 2) {
                MyCartView()
                    .environmentObject(mainVM)
            } else if (homeVM.selectTab == 3) {
                FavouriteView()
                    .environmentObject(mainVM)
            } else if (homeVM.selectTab == 4) { // tran Tab
                AccountView()
                    .environmentObject(mainVM)
            }
            
            // Tab bar
            VStack {
                Spacer()
                
                HStack {
                    TabButton(title: "Shop", icon: "home_tab", isSelect: homeVM.selectTab == 0) { // for animation
                        withAnimation(.spring()) {
                            homeVM.selectTab = 0 // assign for tran Tab
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
                } // HStack
                .padding(.top, 10)
                .padding(.bottom, .bottomInsets)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: -2)
                .scaleEffect(animateTabBar ? 1.0 : 0.8)
                .opacity(animateTabBar ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: animateTabBar)
            } // VStck
        } // ZS
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onAppear {
            animateTabBar = true
            animateGradient = true
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(MainViewModel.shared)
    }
}
