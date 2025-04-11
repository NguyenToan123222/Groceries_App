import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var loginVM: MainViewModel
    @State private var isNavigatingToCustomer = false
    @State private var isNavigatingToAdmin = false
    
    // Biến để điều khiển animation
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animateDescription = false
    @State private var animateEmailField = false
    @State private var animatePasswordField = false
    @State private var animateForgotPassword = false
    @State private var animateLoginButton = false
    @State private var animateSignupLink = false
    
    // Thêm FocusState để kiểm soát focus
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    // Hàm để đóng bàn phím
    func dismissKeyboard() {
        emailFieldIsFocused = false
        passwordFieldIsFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            
            // Image("bg1")
            // Image("bg2")
            // Image("bg3")
            Image("welcome")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Gradient động
            LinearGradient(colors: [Color.purple, Color.blue, Color.pink, Color.orange],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(animateGradient ? 0.3 : 0)
                .hueRotation(.degrees(animateGradient ? 0 : 360))
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            VStack {
                // Logo bay từ trên xuống và xoay
                Image("color_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.bottom, .screenWidth * 0.05)
                    // Xoay 360 và Hiệu ứng xoay mượt mà trong 2 giây, lặp lại mãi mãi, được đảo ngược.
                    .rotationEffect(.degrees(animateLogo ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                    .padding(.trailing, 80)

                
                // Tiêu đề "Login" bay từ bên trái
                Text("Login")
                    .font(.customfont(.semibold, fontSize: 36))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                    .offset(x: animateTitle ? 0 : -300) // Bay từ bên trái
                    .rotationEffect(.degrees(animateTitle ? 0 : -90)) // Xoay nhẹ
                    .scaleEffect(animateTitle ? 1 : 0.3)
                    .opacity(animateTitle ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.4), value: animateTitle)
                    .padding(.trailing, 90)
                    .padding(.bottom, 60)

                // Mô tả "Enter your email and password" bay từ bên phải
                Text("Enter your email and password")
                    .font(.customfont(.semibold, fontSize: 19))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, .screenWidth * 0.1)
                    .offset(x: animateDescription ? 0 : 300) // Bay từ bên phải
                    .rotationEffect(.degrees(animateDescription ? 0 : 90))
                    .scaleEffect(animateDescription ? 1 : 0.3)
                    .opacity(animateDescription ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.6), value: animateDescription)
                    .padding(.trailing, 90)
                

                
                // Trường Email bay từ dưới lên bên trái
                LineTextField(txt: $loginVM.txtEmail, title: "Email", placeholder: "Enter your email address", keyboardType: .emailAddress)
                    .focused($emailFieldIsFocused)
                    .padding(.bottom, .screenWidth * 0.07)
                    .offset(x: animateEmailField ? 0 : -200, y: animateEmailField ? 0 : 300) // Bay từ dưới lên bên trái
                    .rotationEffect(.degrees(animateEmailField ? 0 : -45))
                    .scaleEffect(animateEmailField ? 1 : 0.5)
                    .opacity(animateEmailField ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.8), value: animateEmailField)
                    .padding(.leading,  40)
                    .padding(.trailing, 100)
                
                // Trường Password bay từ dưới lên bên phải
                LineSecureField(title: "Password", placeholder: "Enter your password", txt: $loginVM.txtPassword, isShowPassword: $loginVM.isShowPassword)
                    .focused($passwordFieldIsFocused)
                    .padding(.bottom, .screenWidth * 0.02)
                    .offset(x: animatePasswordField ? 0 : 200, y: animatePasswordField ? 0 : 300) // Bay từ dưới lên bên phải
                    .rotationEffect(.degrees(animatePasswordField ? 0 : 45))
                    .scaleEffect(animatePasswordField ? 1 : 0.5)
                    .opacity(animatePasswordField ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.0), value: animatePasswordField)
                    .padding(.leading,  40)
                    .padding(.trailing, 100)
                
                // "Forgot Password?" bay từ bên phải
                NavigationLink {
                    ForgetPassView()
//                        .environmentObject(loginVM)
                } label: {
                    Text("Forgot Password?")
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, .screenWidth * 0.03)
                .offset(x: animateForgotPassword ? 0 : 300) // Bay từ bên phải
                .scaleEffect(animateForgotPassword ? 1 : 0.5)
                .opacity(animateForgotPassword ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.2), value: animateForgotPassword)
                .padding(.leading,  40)
                .padding(.trailing, 100)
                
                // Nút "Log In" bay từ dưới lên
                RoundButton(tittle: "Log In") {
                    dismissKeyboard()
                    loginVM.serviceCallLogin()
                        
                }
                .padding(.leading,  40)
                .padding(.trailing, 100)
                .padding(.bottom, .screenWidth * 0.05)
                .offset(y: animateLoginButton ? 0 : 300) // Bay từ dưới lên
                .scaleEffect(animateLoginButton ? 1 : 0.5)
                .opacity(animateLoginButton ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.4), value: animateLoginButton)
                
                // Link "Signup" bay từ dưới lên
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
                .offset(y: animateSignupLink ? 0 : 300) // Bay từ dưới lên
                .scaleEffect(animateSignupLink ? 1 : 0.5)
                .opacity(animateSignupLink ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.6), value: animateSignupLink)
                
                Spacer()
            } // VStack
            .padding(.top, .topInsets + 64)
            .padding(.horizontal, 20)
            .padding(.bottom, .bottomInsets)
            
            NavigationLink(
                destination: MainTabView(),
                isActive: $isNavigatingToCustomer,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: AdminView(),
                isActive: $isNavigatingToAdmin,
                label: { EmptyView() }
            )
        } // ZStack
        .alert(isPresented: $loginVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(loginVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .background(Color.white)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
        .onAppear {
            // Kích hoạt các animation
            animateGradient = true
            animateLogo = true
            animateTitle = true
            animateDescription = true
            animateEmailField = true
            animatePasswordField = true
            animateForgotPassword = true
            animateLoginButton = true
            animateSignupLink = true
            
            isNavigatingToCustomer = false
            isNavigatingToAdmin = false
            dismissKeyboard()
            
            loginVM.txtEmail = ""
            loginVM.txtPassword = ""
            loginVM.isShowPassword = false
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
    NavigationView {
        LoginView()
            .environmentObject(MainViewModel.shared)
    }
}
