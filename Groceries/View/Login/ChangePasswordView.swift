import SwiftUI

struct ChangePasswordView: View {
    
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var animateBackground = false
    @State private var animateContent = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    
    @State private var shouldNavigateToLogin = false

    @FocusState private var oldPasswordFieldIsFocused: Bool
    @FocusState private var newPasswordFieldIsFocused: Bool

    func dismissKeyboard() {
        oldPasswordFieldIsFocused = false
        newPasswordFieldIsFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(animateBackground ? 1 : 0)
                .animation(.easeIn(duration: 0.2), value: animateBackground)
            
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismissKeyboard()
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeIn(duration: 1.0).delay(0.3), value: animateContent)
                    
                    Spacer()
                } // H
                .padding(.top, .topInsets)
                .padding(.horizontal, 3)
                
                Text("Change Password")
                    .font(.customfont(.bold, fontSize: 29))
                    .foregroundColor(.primaryText)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeIn(duration: 1.0).delay(0.5), value: animateContent)
                
                VStack(spacing: 16) {
                    LineSecureField(title: "Old Password", placeholder: "Enter your old password", txt: $mainVM.txtOldPassword, isShowPassword: $mainVM.isShowPassword)
                        .focused($oldPasswordFieldIsFocused)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    LineSecureField(title: "New Password", placeholder: "Enter your new password", txt: $mainVM.txtPassword, isShowPassword: $mainVM.isShowPassword)
                        .focused($newPasswordFieldIsFocused)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
                }
                
                RoundButton(tittle: "Change Password") {
                    dismissKeyboard()
                    mainVM.serviceCallChangePassword()
                }
                .scaleEffect(animateContent ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.0), value: animateContent)
                
                Spacer()
                
                NavigationLink(
                    destination: LoginView()
                        .environmentObject(mainVM)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true),
                    isActive: $shouldNavigateToLogin,
                    label: { EmptyView() }
                )
            } // V
            .padding(.horizontal, 15)
            .onAppear {
                animateBackground = true
                animateContent = true
                mainVM.navigateTo = false
                mainVM.navigateToLogin = false
                shouldNavigateToLogin = false
                dismissKeyboard()
            }
            .alert(isPresented: $mainVM.showSuccess) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(mainVM.successMessage),
                    dismissButton: .default(Text("OK")) {
                       
                            shouldNavigateToLogin = true
                        
                    }
                )
            }
            .alert(isPresented: $mainVM.showError) {
                Alert(title: Text(Globs.AppName), message: Text(mainVM.errorMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: mainVM.navigateToLogin) { newValue in
                if newValue {
                    shouldNavigateToLogin = true
                }
            }
            .onDisappear {
                dismissKeyboard()
            }
            .onTapGesture {
                dismissKeyboard()
                /*
                 Khi người dùng tap vào bất kỳ khu vực nào ngoài các trường nhập liệu.
                 Lý do: Cho phép người dùng ẩn bàn phím thủ công bằng cách tap ra ngoài, cải thiện trải nghiệm người dùng.
                 */
            }
            .ignoresSafeArea(.keyboard)
        } // Z
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(MainViewModel.shared)
}
