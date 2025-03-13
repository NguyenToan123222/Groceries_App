//
//  WelcomeView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 16/9/24.
//

import SwiftUI

struct WelcomeView: View {
    
    var body: some View {
        ZStack {
            Image("welcom_bg")
                .resizable()
                .scaledToFill()
                .frame(width: .screenWidth, height: .screenHeight)
            
            VStack {
                Spacer()
                 
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.bottom, 8)
                
                Text ("Welcome\nto our store")
                    .font(.customfont(.semibold, fontSize: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text ("Get your groceries in as fast as one hour")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
               
                NavigationLink {
                    LoginView()
                } label: {
                    RoundButton(tittle: "Get Started") {
                        
                    }
                    
                }
                // bottom frame
                Spacer()
                    .frame(height: 60)
                
                
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationView {
        WelcomeView()
    }
}
