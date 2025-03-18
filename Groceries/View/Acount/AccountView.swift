import SwiftUI

struct AccountView: View {
    @StateObject var mainaccVM = MainViewModel.shared

    var body: some View {
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
            }
            .padding()
            
            List {
                AccountRow(icon: "cart", title: "Orders")
                NavigationLink(destination: ChangePasswordView()) {
                    AccountRow(icon: "person", title: "Change Password")
                }
                NavigationLink(destination: DeliveryAddressView()) {
                    AccountRow(icon: "map", title: "Delivery Address")
                }
                AccountRow(icon: "creditcard", title: "Payment Methods")
                AccountRow(icon: "ticket", title: "Promo Code")
                AccountRow(icon: "bell", title: "Notifications")
                AccountRow(icon: "questionmark.circle", title: "Help")
                AccountRow(icon: "info.circle", title: "About")
            }
            .listStyle(PlainListStyle())

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
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
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
//            Image("next_1")
//                .foregroundColor(.gray)
//                .frame(width: 15, height: 10)
//                
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        AccountView()
    }
}
