import SwiftUI

struct OTPView: View {
    @StateObject var mainVM = MainViewModel.shared
    @State private var otpCode: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isNavigatingToHome: Bool = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State private var animateBackground = false
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Animated Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(animateBackground ? 1 : 0)
                .animation(.easeIn(duration: 1.2), value: animateBackground)
            
            ScrollView {
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
                    Image("color_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.bottom, .screenWidth * 0.05)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.0).delay(0.3), value: animateContent)
                    
                    Text("Verify OTP")
                        .font(.customfont(.bold, fontSize: 26))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.0).delay(0.5), value: animateContent)
                    
                    Text("Enter the OTP sent to \(mainVM.txtEmail)")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .screenWidth * 0.09)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.0).delay(0.7), value: animateContent)
                    
                    LineTextField(txt: $otpCode, title: "OTP Code", placeholder: "Enter OTP", keyboardType: .numberPad)
                        .padding(.bottom, .screenWidth * 0.04)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.9), value: animateContent)
                    
                    RoundButton(tittle: "Verify OTP") {
                        verifyOTP()
                    }
                    .scaleEffect(animateContent ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.2), value: animateContent)
                    .padding(.bottom, .screenWidth * 0.05)
                }
                .padding(.top, .topInsets + 1)
                .padding(.horizontal, 20)
            }
            .onAppear {
                animateBackground = true
                animateContent = true
            }
            
            NavigationLink(
                destination: MainTabView(),
                isActive: $isNavigatingToHome,
                label: { EmptyView() }
            )
        }
        .alert(isPresented: $showError) {
            Alert(title: Text(Globs.AppName), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
    
    func verifyOTP() {
        if otpCode.isEmpty {
            errorMessage = "Please enter the OTP"
            showError = true
            return
        }

        let parameters = [
            "tempToken": mainVM.token,
            "otp": otpCode
        ]

        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_VERIFY_OTP) { responseObj in
            print("Response from verify-otp: \(responseObj)")
            
            if let response = responseObj as? NSDictionary {
                if response["message"] as? String == "OTP is valid. Your account is now verified." {
                    let userDict = Utils.UDValue(key: Globs.userPayload) as? NSMutableDictionary ?? NSMutableDictionary()
                    userDict["isVerified"] = 1
                    self.mainVM.setUserData(uDict: userDict)
                    self.isNavigatingToHome = true
                } else {
                    errorMessage = response["error"] as? String ?? "OTP verification failed"
                    showError = true
                }
            } else {
                errorMessage = "Unexpected response format"
                showError = true
            }
        } failure: { error in
            errorMessage = error?.localizedDescription ?? "Network error"
            showError = true
        }
    }
}

#Preview {
    OTPView()
}
