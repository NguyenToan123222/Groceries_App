import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var mainaccVM: MainViewModel
    
    @State private var animateBackground = false
    @State private var animateHeader = false
    @State private var animateRows = false
    @State private var animateLogoutButton = false
    @State private var shouldNavigateToLogin = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 360 : 0)) // .hueRotation xoay màu sắc (hiệu ứng cầu vồng) dựa trên trạng thái animateBackground, với animation lặp lại mãi mãi trong 5 giây.
                .animation(.linear(duration: 5).repeatForever(autoreverses:  true), value: animateBackground)
                .onAppear {
                    animateBackground = true
                }
            
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(mainaccVM.userObj.email.isEmpty ? "No Email" : mainaccVM.userObj.email)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(mainaccVM.userObj.fullName.isEmpty ? "No Name" : mainaccVM.userObj.fullName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.green)
                } //HStack
                .padding()
                .offset(y: animateHeader ? 0 : -50)
                .opacity(animateHeader ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: animateHeader)
                
                List {
                    NavigationLink(destination: MyOrdersView()) {
                        AccountRow(icon: "cart", title: "Orders")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.1), value: animateRows)
                    } // Mũi tên tự động xuất hiện
                    NavigationLink(destination: ChangePasswordView()
                        .environmentObject(mainaccVM)) {
                        AccountRow(icon: "person", title: "Change Password")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateRows)
                    }
                    NavigationLink(destination: DeliveryAddressView(userId: mainaccVM.userObj.id)
                        .environmentObject(mainaccVM)) {
                        AccountRow(icon: "map", title: "Delivery Address")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateRows)
                    }
            
                    NavigationLink(destination: PromoCodeView()) {
                        AccountRow(icon: "ticket", title: "Promo Code")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.5), value: animateRows)
                    }
                    NavigationLink(destination: NotificationView()) {
                        AccountRow(icon: "bell", title: "Notifications")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateRows)
                    }
                    NavigationLink(destination: HelpView()) {
                        AccountRow(icon: "questionmark.circle", title: "Help")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.7), value: animateRows)
                    }
                    NavigationLink(destination: AboutView()) {
                        AccountRow(icon: "info.circle", title: "About")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.8), value: animateRows)
                    }
                }
                .listStyle(PlainListStyle())// not border
                .frame(maxHeight: 500)
                
                Button(action: {
                    print("Logout pressed")
                    mainaccVM.logout()
                    self.shouldNavigateToLogin = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Log Out")
                            .font(.headline)
                    }
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                } // Button
                .padding(.horizontal)
                .padding(.bottom, 25)
                .scaleEffect(animateLogoutButton ? 1.0 : 0.8)
                .opacity(animateLogoutButton ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateLogoutButton)
                
                NavigationLink(
                    destination: LoginView()
                        .environmentObject(mainaccVM),
                    isActive: $shouldNavigateToLogin,
                    label: { EmptyView() }
                )
            }// Vstack
        } // Zstack
        .onAppear {
            animateHeader = true
            animateRows = true
            animateLogoutButton = true
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true) // Ẩn navigation bar trong AccountView
    }
}

struct AccountRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(title)
                .font(.system(size: 16))
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        AccountView()
            .environmentObject(MainViewModel.shared)
    }
}
