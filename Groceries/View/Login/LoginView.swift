import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var loginVM: MainViewModel// chia sẻ dữ liệu toàn cục cho các view khác : loginVM.isLoggedIn = true .....
    
    @State private var isNavigatingToCustomer = false
    @State private var isNavigatingToAdmin = false
    
    // Đặt giá trị ban đầu là true để logo và gradient hiển thị ngay từ đầu
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animateDescription = false
    @State private var animateEmailField = false
    @State private var animatePasswordField = false
    @State private var animateForgotPassword = false
    @State private var animateLoginButton = false
    @State private var animateSignupLink = false
    
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    func dismissKeyboard() {
        emailFieldIsFocused = false
        passwordFieldIsFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            Image("welcome")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(colors: [Color.purple, Color.blue, Color.pink, Color.orange],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
                .hueRotation(.degrees(animateGradient ? 0 : 360))
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            ScrollView {
                VStack {
                    Image("color_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.bottom, .screenWidth * 0.05)
                        .rotationEffect(.degrees(animateLogo ? 360 : 0))
                        .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateLogo)
                        .padding(.trailing, 75)
                
                    Text("Login")
                        .font(.customfont(.semibold, fontSize: 36))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                        .offset(x: animateTitle ? 0 : -300) // Di chuyển từ -300 (trái) về 0
                        .rotationEffect(.degrees(animateTitle ? 0 : -90))
                        .scaleEffect(animateTitle ? 1 : 0.3) // Phóng to từ 0.3x lên 1x
                        .opacity(animateTitle ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.4), value: animateTitle)
                         /*
                          response: 0.5: Thời gian phản hồi (0.5 giây), xác định tốc độ ban đầu của animation.
                          dampingFraction: 0.6: Mức độ giảm xóc (0 đến 1), 0.6 tạo hiệu ứng bật nhẹ, không quá mạnh.
                          blendDuration: 0: Thời gian hòa trộn giữa các animation (0 nghĩa là không hòa trộn).
                          -> "Login" sẽ di chuyển, xoay, scale, và opacity thay đổi với hiệu ứng bật nhẹ trong 0.5 giây, bắt đầu sau 0.4 giây.
                          */
                        .padding(.trailing, 55)
                        .padding(.bottom, 40)

                    Text("Enter your email and password")
                        .font(.customfont(.semibold, fontSize: 19))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, .screenWidth * 0.1)
                        .offset(x: animateDescription ? 0 : 300)
                        .rotationEffect(.degrees(animateDescription ? 0 : 90))
                        .scaleEffect(animateDescription ? 1 : 0.3)
                        .opacity(animateDescription ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.6), value: animateDescription)
                        .padding(.trailing, 90)
                        .padding(.bottom, 45)

                    LineTextField(txt: $loginVM.txtEmail, title: "Email", placeholder: "Enter your email address", keyboardType: .emailAddress)
                        .focused($emailFieldIsFocused)
                        .padding(.bottom, .screenWidth * 0.07)
                        .offset(x: animateEmailField ? 0 : -200, y: animateEmailField ? 0 : 300)
                        .rotationEffect(.degrees(animateEmailField ? 0 : -45))
                        .scaleEffect(animateEmailField ? 1 : 0.5)
                        .opacity(animateEmailField ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.8), value: animateEmailField)
                        .padding(.leading, 50)
                        .padding(.trailing, 106)
                
                    LineSecureField(title: "Password", placeholder: "Enter your password", txt: $loginVM.txtPassword, isShowPassword: $loginVM.isShowPassword)
                        .focused($passwordFieldIsFocused) // true when clicked
                        .padding(.bottom, .screenWidth * 0.02)
                        .offset(x: animatePasswordField ? 0 : 200, y: animatePasswordField ? 0 : 300)
                        .rotationEffect(.degrees(animatePasswordField ? 0 : 45))
                        .scaleEffect(animatePasswordField ? 1 : 0.5)
                        .opacity(animatePasswordField ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.0), value: animatePasswordField)
                        .padding(.leading, 50)
                        .padding(.trailing, 106)
                
                    NavigationLink {
                        ForgetPassView()
                    } label: {
                        Text("Forgot Password?")
                            .font(.customfont(.medium, fontSize: 14))
                            .foregroundColor(.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, .screenWidth * 0.03)
                    .offset(x: animateForgotPassword ? 0 : 300)
                    .scaleEffect(animateForgotPassword ? 1 : 0.5)
                    .opacity(animateForgotPassword ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.2), value: animateForgotPassword)
                    .padding(.leading, 50)
                    .padding(.trailing, 106)
                
                    RoundButton(tittle: "Log In") {
                        dismissKeyboard()
                        loginVM.serviceCallLogin()
                    }
                    .padding(.leading, 45)
                    .padding(.trailing, 106)
                    .padding(.bottom, .screenWidth * 0.05)
                    .offset(y: animateLoginButton ? 0 : 300)
                    .scaleEffect(animateLoginButton ? 1 : 0.5)
                    .opacity(animateLoginButton ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.4), value: animateLoginButton)
                
                    NavigationLink {
                        SignUpView()
                            .environmentObject(loginVM)
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
                    .offset(y: animateSignupLink ? 0 : 300)
                    .scaleEffect(animateSignupLink ? 1 : 0.5)
                    .opacity(animateSignupLink ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.6), value: animateSignupLink)
                
                    Spacer()
                
                    NavigationLink(
                        destination: MainTabView()
                            .environmentObject(loginVM),
                        isActive: $isNavigatingToCustomer,
                        label: { EmptyView() }
                    )
                
                    NavigationLink(
                        destination: AdminView()
                            .environmentObject(loginVM),
                        isActive: $isNavigatingToAdmin,
                        label: { EmptyView() }
                    )
                } // Vstack 1
                .padding(.top, .topInsets + 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 300)
            } // Scroll
            .ignoresSafeArea(.keyboard)
            
            VStack {
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)
        } // ZStack
        .alert(isPresented: $loginVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(loginVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            // Đảm bảo các trạng thái khác vẫn được kích hoạt
            animateGradient = true
            animateTitle = true
            animateDescription = true
            animateLogo = true
            animateEmailField = true
            animatePasswordField = true
            animateForgotPassword = true
            animateLoginButton = true
            animateSignupLink = true
            
            dismissKeyboard()
            
            loginVM.navigateTo = false
            loginVM.navigateToLogin = false
        }
        
        .onChange(of: loginVM.navigateTo) { newValue in
            if newValue {
                dismissKeyboard()
                if loginVM.isAdmin() {
                    isNavigatingToAdmin = true
                } else {
                    isNavigatingToCustomer = true
                }
            }
        }
        .onDisappear {
            dismissKeyboard()
        }
        .onTapGesture {
            dismissKeyboard()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    LoginView()
        .environmentObject(MainViewModel.shared)
}
