//
//  AddressRowView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 12/4/25.
//

import SwiftUI
// Sử dụng DeliveryAddressViewModel (quản lý địa chỉ) và MainViewModel (quản lý thông tin người dùng).
struct AddressRowView: View {
    
    let address: AddressModel
    @StateObject var deliveryVM = DeliveryAddressViewModel.shared
    // Giữ deliveryVM trong suốt vòng đời view, theo dõi thay đổi (như @Published properties).
    @EnvironmentObject var mainVM: MainViewModel
    // Cung cấp thông tin người dùng (như userObj.id) để kiểm tra đăng nhập.
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(address.street)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // address.provinceId lấy "value" thay vì dùng id chỉ lấy "key"
                /*
                 User : AddressModel(id: "abc123", userId: 1, street: "123 Main Street", provinceId: 1, districtId: 1, wardId: 1, isDefault: true)
                 
                   provinceNames = [1: "Hà Nội", 2: "TP.HCM"]
                   districtNames = [1: "Cầu Giấy", 2: "Quận 1"]
                   wardNames = [1: "Dịch Vọng", 2: "Bến Nghé"] */
                Text("Province: \(deliveryVM.provinceNames[address.provinceId] ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("District: \(deliveryVM.districtNames[address.districtId] ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Ward: \(deliveryVM.wardNames[address.wardId] ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if address.isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(5)
                }
            }
            
            VStack {
                NavigationLink {
                    AddDeliveryAddressView(isEdit: true, editAddress: address)
                        .environmentObject(mainVM)
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 8)
                
                Button {
                    if mainVM.userObj.id == 0 {
                        deliveryVM.errorMessage = "Please log in to manage addresses"
                        deliveryVM.showError = true
                        return // Ngăn gọi API xóa nếu chưa đăng nhập
                    }
                    deliveryVM.serviceCallRemove(addressId: address.id, userId: mainVM.userObj.id)
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                
                if !address.isDefault { // isDefault == false || not Default
                    Button {
                        if mainVM.userObj.id == 0 {
                            deliveryVM.errorMessage = "Please log in to manage addresses"
                            deliveryVM.showError = true
                            return
                        }
                        // Tạo một instance mới của AddressModel với các thông tin giống địa chỉ hiện tại, nhưng đặt isDefault = true.
                        deliveryVM.serviceCallUpdateAddress(aObj: AddressModel(
                            id: address.id,
                            userId: address.userId,
                            street: address.street,
                            provinceId: address.provinceId,
                            districtId: address.districtId,
                            wardId: address.wardId,
                            isDefault: true
                        ), userId: mainVM.userObj.id, didDone: nil)
                    } label: {
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
        } // Hstack
        
        .padding(15)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        // Bỏ đoạn .onAppear vì không cần gọi fetchLocationNames nữa
    } // body
}

struct AddressRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAddress = AddressModel(
            id: UUID().uuidString,
            userId: 1,
            street: "123 Main Street",
            provinceId: 1,
            districtId: 1,
            wardId: 1,
            isDefault: true
        )
        
         NavigationView {
            AddressRowView(address: sampleAddress)
                .environmentObject(MainViewModel.shared)
        }
    }
}
