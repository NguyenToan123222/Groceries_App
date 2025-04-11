import SwiftUI

struct ChangePasswordView: View {
//    @StateObject var mainVM = MainViewModel.shared
    @EnvironmentObject var mainVM: MainViewModel
    @State private var isNavigatingToLogin = false
    @State private var animateBackground = false
    @State private var animateContent = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    // Thêm FocusState để kiểm soát bàn phím
    @FocusState private var oldPasswordFieldIsFocused: Bool
    @FocusState private var newPasswordFieldIsFocused: Bool

    // Hàm để đóng bàn phím
    func dismissKeyboard() {
        oldPasswordFieldIsFocused = false
        newPasswordFieldIsFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            // Animated Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(animateBackground ? 1 : 0)
                .animation(.easeIn(duration: 1.2), value: animateBackground)
            
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismissKeyboard() // Đóng bàn phím trước khi quay lại
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
                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 3)
                
                // Title with fade-in effect
                Text("Change Password")
                    .font(.customfont(.bold, fontSize: 29))
                    .foregroundColor(.primaryText)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeIn(duration: 1.0).delay(0.5), value: animateContent)
                    
                // Input fields with slide-in effect
                VStack(spacing: 16) {
                    LineSecureField(title: "Old Password", placeholder: "Enter your old password", txt: $mainVM.txtOldPassword, isShowPassword: $mainVM.isShowPassword)
                        .focused($oldPasswordFieldIsFocused) // Gắn FocusState
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    LineSecureField(title: "New Password", placeholder: "Enter your new password", txt: $mainVM.txtPassword, isShowPassword: $mainVM.isShowPassword)
                        .focused($newPasswordFieldIsFocused) // Gắn FocusState
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
                } // VStack
                
                // Animated Button
                RoundButton(tittle: "Change Password") {
                    dismissKeyboard() // Đóng bàn phím trước khi gọi API
                    mainVM.serviceCallChangePassword()
                    
                }
                .scaleEffect(animateContent ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(1.0), value: animateContent)
                
                Spacer()
            }// VStack
            .padding(.horizontal, 15)
            .onAppear {
                animateBackground = true
                animateContent = true
                
                // Đặt lại trạng thái điều hướng
                mainVM.navigateTo = false
                mainVM.navigateToLogin = false
                isNavigatingToLogin = false
                dismissKeyboard()
            }
            .alert(isPresented: $mainVM.showSuccess) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(mainVM.successMessage),
                    dismissButton: .default(Text("OK")) {
                        if mainVM.navigateToLogin {
                            dismissKeyboard() // Đóng bàn phím trước khi điều hướng
                            // Đảm bảo điều hướng đồng bộ
                            mode.wrappedValue.dismiss()
                            isNavigatingToLogin = true
                            
                        }
                    }
                )
            }
            .alert(isPresented: $mainVM.showError) {
                Alert(title: Text(Globs.AppName), message: Text(mainVM.errorMessage), dismissButton: .default(Text("OK")))
            }
            .overlay(
                NavigationLink(
                    destination: LoginView(),
                    isActive: $isNavigatingToLogin,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .onChange(of: mainVM.navigateToLogin) { newValue in
                if newValue {
                    dismissKeyboard() // Đóng bàn phím trước khi điều hướng
                    mode.wrappedValue.dismiss()
                    isNavigatingToLogin = true
                }
            }
            .onDisappear {
                dismissKeyboard()
            }
            .onTapGesture {
                dismissKeyboard()
            }
            // Thêm modifier để ngăn bàn phím tự động mở
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(MainViewModel.shared)
}
