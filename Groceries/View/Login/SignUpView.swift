import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    @StateObject var mainVM = MainViewModel.shared
    @State private var isNavigatingTo = false
    @State private var passwordError: String?
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var animateFields = false
    
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
            
            ScrollView {
                VStack {
                    Image("color_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.bottom, .screenWidth * 0.05)
                        // Xoay 360 và Hiệu ứng xoay mượt mà trong 2 giây, lặp lại mãi mãi, được đảo ngược.
                        .rotationEffect(.degrees(animateLogo ? 360 : 0))
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                    
                    Text("Sign Up")
                        .font(.customfont(.bold, fontSize: 26))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                        .opacity(animateFields ? 1 : 0)
                        .offset(y: animateFields ? 0 : 20)
                        .animation(.easeInOut(duration: 1), value: animateFields)
                    
                    Text("Enter your credentials to continue")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .screenWidth * 0.09)
                        .opacity(animateFields ? 1 : 0)
                        .offset(y: animateFields ? 0 : 20)
                        .animation(.easeInOut(duration: 1).delay(0.2), value: animateFields)
                    
                    Group {
                        LineTextField(txt: $mainVM.txtFullName, title: "User name", placeholder: "Enter your username")
                        LineTextField(txt: $mainVM.txtEmail, title: "Email", placeholder: "Enter your email address", keyboardType: .emailAddress)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let error = passwordError {
                                Text(error)
                                    .font(.customfont(.regular, fontSize: 12))
                                    .foregroundColor(.red)
                            }
                            LineSecureField(title: "Password", placeholder: "Enter your password", txt: $mainVM.txtPassword, isShowPassword: $mainVM.isShowPassword)
                        }
                        
                        LineTextField(txt: $mainVM.txtPhone, title: "Phone", placeholder: "Enter your phone number", keyboardType: .phonePad)
                        LineTextField(txt: $mainVM.txtAddress, title: "Address", placeholder: "Enter your address")
                    }
                    .padding(.bottom, .screenWidth * 0.04)
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 20)
                    .animation(.easeInOut(duration: 1).delay(0.3), value: animateFields)
                    
                    VStack {
                        Text("By continuing you agree to our")
                            .font(.customfont(.medium, fontSize: 14))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Term of Service")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.primaryApp)
                            
                            Text(" and ")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.secondaryText)
                            
                            Text("Privacy Policy")
                                .font(.customfont(.medium, fontSize: 14))
                                .foregroundColor(.primaryApp)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, .screenWidth * 0.02)
                    }
                    
                    RoundButton(tittle: "Sign Up") {
                        passwordError = mainVM.txtPassword.isEmpty ? "Please enter a valid password" : nil
                        if passwordError == nil {
                            mainVM.serviceCallSignUp()
                        }
                    }
                    .padding(.bottom, .screenWidth * 0.05)
                    .scaleEffect(animateFields ? 1 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateFields)
                    
                    NavigationLink {
                        LoginView()
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
                    .opacity(animateFields ? 1 : 0)
                    .animation(.easeInOut(duration: 1).delay(0.5), value: animateFields)
                    
                } // VStack
                .padding(.top, .topInsets + 1)
                .padding(.horizontal, 20)
            } // Scroll
            
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
        } // ZStack
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
            animateFields = true
        }
        .onChange(of: mainVM.navigateTo) { newValue in
            if newValue {
                isNavigatingTo = true
            }
        }
    }
}

#Preview {
    SignUpView()
}
