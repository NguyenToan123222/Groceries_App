//
//  AdminAccountDetailView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 24/4/25.
//

import SwiftUI

struct AdminAccountDetailView: View {
    @StateObject var detailVM: AdminAccountDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Account Details")
                    .font(.customfont(.bold, fontSize: 26))
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 20)
                    .padding(.top, .topInsets)

                // User Info
                userInfoSection

                // Addresses
                addressesSection
            }
        }
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        //.background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Account Details")
        .alert(isPresented: $detailVM.showError) {
            Alert(
                title: Text(Globs.AppName),
                message: Text(detailVM.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Full Name: \(detailVM.user.fullName)")
                .font(.customfont(.semibold, fontSize: 18))
                .foregroundColor(.primaryText)
            
            Text("Email: \(detailVM.user.email)")
                .font(.customfont(.regular, fontSize: 16))
                .foregroundColor(.secondaryText)
            
            Text("Phone: \(detailVM.user.phone)")
                .font(.customfont(.regular, fontSize: 16))
                .foregroundColor(.secondaryText)
            
            Text("Role: \(detailVM.user.role)")
                .font(.customfont(.regular, fontSize: 16))
                .foregroundColor(.secondaryText)
            
            Text("Created At: \(detailVM.user.createdAt.displayDate(format: "yyyy-MM-dd hh:mm a"))")
                .font(.customfont(.regular, fontSize: 16))
                .foregroundColor(.secondaryText)
            
            Text("Verified: \(detailVM.user.isVerified ? "Yes" : "No")")
                .font(.customfont(.regular, fontSize: 16))
                .foregroundColor(detailVM.user.isVerified ? .green : .red)
        }
        .padding(.horizontal, 20)
    }

    private var addressesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Addresses")
                .font(.customfont(.semibold, fontSize: 20))
                .foregroundColor(.primaryText)
            
            if detailVM.user.address.isEmpty {
                Text("No addresses available")
                    .font(.customfont(.medium, fontSize: 16))
                    .foregroundColor(.secondaryText)
            } else {
                addressRow(for: detailVM.user.address)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, .bottomInsets + 20)
    }

    private func addressRow(for address: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(address)
                .font(.customfont(.medium, fontSize: 16))
                .foregroundColor(.primaryText)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
}

#Preview {
    NavigationView {
        AdminAccountDetailView(detailVM: AdminAccountDetailViewModel(userId: 1))
    }
}
