//
//  DeliveryAddressView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 17/3/25.
//
import SwiftUI

struct DeliveryAddressView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var deliveryVM = DeliveryAddressViewModel.shared
    
    let userId: Int // Thêm tham số userId
    @State private var isPicker = false
    var didSelect: ((AddressModel) -> Void)?
    /*
     VStack chứa header, được cố định ở đầu nhờ .padding(.top, .topInsets) và Spacer().
     ScrollView được dịch xuống dưới nhờ .padding(.top, .topInsets + 46), tránh chồng lấn với header.
     */
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(deliveryVM.listArr) { address in
                        AddressRowView(address: address)
                            .onTapGesture {
                                if isPicker {
                                    presentationMode.wrappedValue.dismiss()
                                    didSelect?(address)
                                    /*
                                     onTapGesture: Khi người dùng nhấn vào một địa chỉ:
                                     Nếu isPicker là true, đóng view và gọi didSelect với địa chỉ đã chọn.
                                     Nếu false, không làm gì (chỉ xem).
                                     */
                                }
                            }
                    }
                }
                .padding(20)
                .padding(.top, .topInsets + 46)
                .padding(.bottom, .bottomInsets + 60)
            } // Scroll
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Delivery Addresses")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    NavigationLink {
                        AddDeliveryAddressView()
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(radius: 2)
                
                Spacer() // Bottom
            } // VStack
        } // Zstack
        .environmentObject(MainViewModel.shared) // Add this to provide MainViewModel to all child views
        .onAppear {
            if userId == 0 {
                deliveryVM.errorMessage = "Please log in to view addresses"
                deliveryVM.showError = true
                return
            }
            deliveryVM.serviceCallList(userId: userId) // lấy danh sách địa chỉ của người dùng
        }
        .alert(isPresented: $deliveryVM.showError) {
            Alert(title: Text("Error"), message: Text(deliveryVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $deliveryVM.showSuccess) {
            Alert(title: Text("Success"), message: Text(deliveryVM.successMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct DeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeliveryAddressView(userId: 1)
                .environmentObject(MainViewModel.shared) // Add this for preview
        }
    }
}

/*
 {
   "content": [
     {
       "id": "550e8400-e29b-41d4-a716-446655440000",
       "street": "123 Đường ABC",
       "provinceId": 1,
       "districtId": 101,
       "wardId": 1001,
       "userId": 500,
       "isDefault": true
     },
     {
       "id": "550e8400-e29b-41d4-a716-446655440001",
       "street": "456 Đường XYZ",
       "provinceId": 2,
       "districtId": 201,
       "wardId": 2001,
       "userId": 500,
       "isDefault": false
     }
   ]
 }*/
