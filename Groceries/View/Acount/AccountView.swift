import SwiftUI

struct AccountView: View {
    @StateObject var mainaccVM = MainViewModel.shared
    
    @State private var animateBackground = false // Biến điều khiển animation background
    @State private var animateHeader = false // Biến điều khiển animation phần thông tin người dùng
    @State private var animateRows = false // Biến điều khiển animation các AccountRow
    @State private var animateLogoutButton = false // Biến điều khiển animation nút Log Out
    
    var body: some View {
        ZStack {
            // Gradient background động
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 360 : 0)) // Hiệu ứng đổi màu gradient
                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animateBackground)
                .onAppear {
                    animateBackground = true // Kích hoạt animation background
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
                } // HStack
                .padding()
                .offset(y: animateHeader ? 0 : -50) // Trượt từ trên xuống
                .opacity(animateHeader ? 1 : 0) // Hiệu ứng mờ dần
                .animation(.easeInOut(duration: 0.5), value: animateHeader)
                
                List {
                    NavigationLink(destination: MyOrdersView()) {
                        AccountRow(icon: "cart", title: "Orders")
                            .offset(x: animateRows ? 0 : -50) // Trượt từ trái sang
                            .opacity(animateRows ? 1 : 0) // Hiệu ứng mờ dần
                            .animation(.easeInOut(duration: 0.5).delay(0.1), value: animateRows)
                    }
                    NavigationLink(destination: ChangePasswordView()) {
                        AccountRow(icon: "person", title: "Change Password")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateRows)
                    }
                    NavigationLink(destination: DeliveryAddressView()) {
                        AccountRow(icon: "map", title: "Delivery Address")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateRows)
                    }
                    NavigationLink(destination: PaymentMethodsView()) {
                        AccountRow(icon: "creditcard", title: "Payment Methods")
                            .offset(x: animateRows ? 0 : -50)
                            .opacity(animateRows ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateRows)
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
                } // List
                .listStyle(PlainListStyle())
                .frame(maxHeight: 500) // Giới hạn chiều cao của List
                
                Button(action: {
                    print("Logout pressed")
                    mainaccVM.logout()
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
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
                .scaleEffect(animateLogoutButton ? 1.0 : 0.8) // Phóng to khi xuất hiện
                .opacity(animateLogoutButton ? 1.0 : 0.0) // Hiệu ứng mờ dần
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateLogoutButton)
                
                // Thêm NavigationLink để điều hướng về LoginView
                NavigationLink(
                    destination: LoginView()
                    .environmentObject(mainaccVM), // Truyền MainViewModel vào môi trường
                    isActive: $mainaccVM.navigateToLogin,
                    label: { EmptyView() }
                )
            } // VStack
        }
        .onAppear {
            animateHeader = true // Kích hoạt animation phần thông tin người dùng
            animateRows = true // Kích hoạt animation các AccountRow
            animateLogoutButton = true // Kích hoạt animation nút Log Out
        }
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
    }
}
