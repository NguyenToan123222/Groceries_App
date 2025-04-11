import SwiftUI

struct ForgetPassView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var mainVM = MainViewModel.shared
    @State private var step: Int = 1
    @State private var animateBackground = false
    @State private var animateLogo = false
    
    var body: some View {
        ZStack {
            // Animated Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(animateBackground ? 1 : 0)
                .animation(.easeIn(duration: 1.2), value: animateBackground)
            
            VStack(spacing: 20) {
                // Back button
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
                .padding(.top, 10)
                .padding(.horizontal, 3)
                
                // Animated Logo
                Image("color_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .scaleEffect(animateLogo ? 1.5 : 1.1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateLogo)
                
                // Title with Fade-in Effect
                Text("Reset your Password")
                    .foregroundColor(.primaryText)
                    .bold()
                    .font(.customfont(.bold, fontSize: 29))
                    .opacity(animateBackground ? 1 : 0)
                    .animation(.easeIn(duration: 1.0).delay(0.3), value: animateBackground)
                    .padding(.bottom, 10)
                
                // Step Transition Animation
                if step == 1 {
                    StepOneView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    StepTwoView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 50)
            .alert(isPresented: $mainVM.showError) {
                Alert(title: Text(Globs.AppName), message: Text(mainVM.errorMessage), dismissButton: .default(Text("OK")))
            }
            
            .alert(isPresented: $mainVM.showSuccess) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(mainVM.successMessage),
                    dismissButton: .default(Text("OK")) {
                        if mainVM.navigationResettoLog {
                            mode.wrappedValue.dismiss()
                        } else if step == 1 {
                            withAnimation { step = 2 }
                        }
                    }
                )
            }
            
            .onAppear {
                animateBackground = true
                animateLogo = true
            }
        }// ZStack
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard)
    }
    
    // Step 1 View
    @ViewBuilder
    private func StepOneView() -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Please provide the email address that you used when you signed up for your account.")
                .multilineTextAlignment(.center)
                .font(.customfont(.medium, fontSize: 18))
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.customfont(.semibold, fontSize: 16))
                
                TextField("test@gmail.com", text: $mainVM.txtEmail)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
            }
            .padding(.horizontal, 20)
            
            Button(action: { mainVM.serviceCallSendOTP() }) {
                Text("Send OTP")
                    .font(.customfont(.semibold, fontSize: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    // Step 2 View
    @ViewBuilder
    private func StepTwoView() -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Enter the OTP sent to \(mainVM.txtEmail) and your new password.")
                .multilineTextAlignment(.center)
                .font(.customfont(.medium, fontSize: 18))
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("OTP Code")
                    .font(.customfont(.semibold, fontSize: 16))
                
                TextField("Enter OTP", text: $mainVM.otpCode)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("New Password")
                    .font(.customfont(.semibold, fontSize: 16))
                
                SecureField("Enter new password", text: $mainVM.txtPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 20)
            
            Button(action: { mainVM.serviceCallResetPassword() }) {
                Text("Reset Password")
                    .font(.customfont(.semibold, fontSize: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

#Preview {
    ForgetPassView()
}
