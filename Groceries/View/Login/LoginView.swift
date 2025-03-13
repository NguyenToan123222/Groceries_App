import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var loginVM = MainViewModel.shared
    @State private var isNavigatingTo = false
    
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            // Gradient động
            LinearGradient(colors: [Color.purple, Color.blue, Color.pink, Color.orange],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
                .hueRotation(.degrees(animateGradient ? 0 : 360))
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            VStack {
                Image("color_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.bottom, .screenWidth * 0.1)
                    // Xoay 360 và Hiệu ứng xoay mượt mà trong 2 giây, lặp lại mãi mãi, được đảo ngược.
                    .rotationEffect(.degrees(animateLogo ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                
                Text("Login")
                    .font(.customfont(.semibold, fontSize: 26))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20) // Dịch chuyển theo trục Y, 0 nếu hiển thị, 20 nếu ẩn (tạo hiệu ứng trượt lên).
                    .animation(.easeInOut(duration: 3), value: animateText)
                
                Text("Enter your email and password")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, .screenWidth * 0.1)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeInOut(duration: 1).delay(0.2), value: animateText)
                
                LineTextField(txt: $loginVM.txtEmail, title: "Email", placeholder: "Enter your email address", keyboardType: .emailAddress)
                    .padding(.bottom, .screenWidth * 0.07)
                
                LineSecureField(title: "Password", placeholder: "Enter your password", txt: $loginVM.txtPassword, isShowPassword: $loginVM.isShowPassword)
                    .padding(.bottom, .screenWidth * 0.02)
                
                NavigationLink {
                    ForgetPassView()
                } label: {
                    Text("Forgot Password?")
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, .screenWidth * 0.03)
                
                RoundButton(tittle: "Log In") {
                    loginVM.serviceCallLogin()
                }
                .padding(.bottom, .screenWidth * 0.05)
                .scaleEffect(animateText ? 1 : 0.8) // Phóng to/thu nhỏ nút (1 hoặc 0.8)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateText)
                
                NavigationLink {
                    SignUpView()
                } label: {
                    HStack {
                        Text("Don't have an account?")
                            .font(.customfont(.semibold, fontSize: 14))
                            .foregroundColor(.primaryText)
                        Text("Signup")
                            .font(.customfont(.semibold, fontSize: 14))
                            .foregroundColor(.primaryApp)
                    }
                }
                
                Spacer()
            }
            .padding(.top, .topInsets + 64)
            .padding(.horizontal, 20)
            .padding(.bottom, .bottomInsets)
            
            NavigationLink(
                destination: MainTabView(),
                isActive: $isNavigatingTo,
                label: { EmptyView() }
            )
        }
        .alert(isPresented: $loginVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(loginVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .background(Color.white)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
            animateLogo = true
            animateText = true
        }
        .onChange(of: loginVM.navigateTo) { newValue in
            if newValue {
                isNavigatingTo = true
            }
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
