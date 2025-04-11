
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var mainVM: MainViewModel
    @State private var isNavigatingTo = false
    @State private var passwordError: String?
    
    // Biến để điều khiển animation
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animateDescription = false
    @State private var animateUsernameField = false
    @State private var animateEmailField = false
    @State private var animatePasswordField = false
    @State private var animatePhoneField = false
    @State private var animateAddressField = false
    @State private var animateTerms = false
    @State private var animateSignUpButton = false
    @State private var animateSignInLink = false
    
    var body: some View {
        ZStack {
            // Background
            Image("welcome")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Gradient động
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
                        .offset(y: animateLogo ? 0 : -200) // Bay từ trên xuống
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                        .padding(.trailing, 75)
                    
                    Text("Sign Up")
                        .font(.customfont(.bold, fontSize: 26))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                        .offset(x: animateTitle ? 0 : -300) // Bay từ bên trái
                        .rotationEffect(.degrees(animateTitle ? 0 : -90))
                        .scaleEffect(animateTitle ? 1 : 0.3)
                        .opacity(animateTitle ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.4), value: animateTitle)
                        .padding(.trailing, 55)
                    
                    Text("Enter your credentials to continue")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .screenWidth * 0.09)
                        .offset(x: animateDescription ? 0 : 300) // Bay từ bên phải
                        .rotationEffect(.degrees(animateDescription ? 0 : 90))
                        .scaleEffect(animateDescription ? 1 : 0.3)
                        .opacity(animateDescription ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.6), value: animateDescription)
                        .padding(.leading, 105)
                    
                    Group {
                        LineTextField(txt: $mainVM.txtFullName, title: "User name", placeholder: "Enter your username")
                            .padding(.leading, 50)
                            .padding(.trailing, 106)
                            .offset(x: animateUsernameField ? 0 : -200, y: animateUsernameField ? 0 : 300)
                            .rotationEffect(.degrees(animateUsernameField ? 0 : -45))
                            .scaleEffect(animateUsernameField ? 1 : 0.5)
                            .opacity(animateUsernameField ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.8), value: animateUsernameField)

                        LineTextField(txt: $mainVM.txtEmail, title: "Email", placeholder: "Enter your email address", keyboardType: .emailAddress)
                            .padding(.leading, 50)
                            .padding(.trailing, 106)
                            .offset(x: animateEmailField ? 0 : 200, y: animateEmailField ? 0 : 300)
                            .rotationEffect(.degrees(animateEmailField ? 0 : 45))
                            .scaleEffect(animateEmailField ? 1 : 0.5)
                            .opacity(animateEmailField ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.0), value: animateEmailField)

                        VStack(alignment: .leading, spacing: 4) {
                            if let error = passwordError {
                                Text(error)
                                    .font(.customfont(.regular, fontSize: 12))
                                    .foregroundColor(.red)
                            }
                            LineSecureField(title: "Password", placeholder: "Enter your password", txt: $mainVM.txtPassword, isShowPassword: $mainVM.isShowPassword)
                                .padding(.leading, 50)
                                .padding(.trailing, 106)
                                .offset(x: animatePasswordField ? 0 : -200, y: animatePasswordField ? 0 : 300)
                                .rotationEffect(.degrees(animatePasswordField ? 0 : -45))
                                .scaleEffect(animatePasswordField ? 1 : 0.5)
                                .opacity(animatePasswordField ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.2), value: animatePasswordField)
                        }

                        LineTextField(txt: $mainVM.txtPhone, title: "Phone", placeholder: "Enter your phone number", keyboardType: .phonePad)
                            .padding(.leading, 50)
                            .padding(.trailing, 106)
                            .offset(x: animatePhoneField ? 0 : 200, y: animatePhoneField ? 0 : 300)
                            .rotationEffect(.degrees(animatePhoneField ? 0 : 45))
                            .scaleEffect(animatePhoneField ? 1 : 0.5)
                            .opacity(animatePhoneField ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.4), value: animatePhoneField)

                        LineTextField(txt: $mainVM.txtAddress, title: "Address", placeholder: "Enter your address")
                            .padding(.leading, 50)
                            .padding(.trailing, 106)
                            .offset(y: animateAddressField ? 0 : 300)
                            .scaleEffect(animateAddressField ? 1 : 0.5)
                            .opacity(animateAddressField ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.6), value: animateAddressField)
                    }
                    .padding(.bottom, .screenWidth * 0.04)

                    VStack {
                        Text("By continuing you agree to our")
                            .font(.customfont(.medium, fontSize: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Term of Service")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.primaryApp)
                            
                            Text(" and ")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.black)
                            
                            Text("Privacy Policy")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.primaryApp)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, .screenWidth * 0.02)
                    }
                    .padding(.leading, 145)
                    .padding(.trailing, 106)
                    .offset(x: animateTerms ? 0 : 300)
                    .scaleEffect(animateTerms ? 1 : 0.5)
                    .opacity(animateTerms ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.8), value: animateTerms)

                    RoundButton(tittle: "Sign Up") {
                        passwordError = mainVM.txtPassword.isEmpty ? "Please enter a valid password" : nil
                        if passwordError == nil {
                            mainVM.serviceCallSignUp()
                        }
                    }
                    .padding(.leading, 45)
                    .padding(.trailing, 106)
                    .padding(.bottom, .screenWidth * 0.05)
                    .offset(y: animateSignUpButton ? 0 : 300)
                    .scaleEffect(animateSignUpButton ? 1 : 0.5)
                    .opacity(animateSignUpButton ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(2.0), value: animateSignUpButton)

                    NavigationLink {
                        LoginView()
                            .environmentObject(mainVM) // Truyền MainViewModel cho LoginView
                    } label: {
                        HStack {
                            Text("Already have an account?")
                                .font(.customfont(.semibold, fontSize: 14))
                                .foregroundColor(.primaryText)
                            Text("Sign in")
                                .font(.customfont(.semibold, fontSize: 14))
                                .foregroundColor(.primaryApp)
                        }
                    }
                    .offset(y: animateSignInLink ? 0 : 300)
                    .scaleEffect(animateSignInLink ? 1 : 0.5)
                    .opacity(animateSignInLink ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(2.2), value: animateSignInLink)
                }
                .padding(.top, .topInsets + 1)
                .padding(.horizontal, 20)
            }
            
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
            
            NavigationLink(
                destination: OTPView(),
                isActive: $isNavigatingTo,
                label: { EmptyView() }
            )
        }
        .alert(isPresented: $mainVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(mainVM.errorMessage), dismissButton: .default(Text("Ok")))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
            animateLogo = true
            animateTitle = true
            animateDescription = true
            animateUsernameField = true
            animateEmailField = true
            animatePasswordField = true
            animatePhoneField = true
            animateAddressField = true
            animateTerms = true
            animateSignUpButton = true
            animateSignInLink = true
            
            // Đặt lại trạng thái điều hướng
            isNavigatingTo = false
            mainVM.navigateTo = false
        }
        .onChange(of: mainVM.navigateToOTP) { newValue in
            if newValue {
                isNavigatingTo = true
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView()
            .environmentObject(MainViewModel.shared)
    }
}
