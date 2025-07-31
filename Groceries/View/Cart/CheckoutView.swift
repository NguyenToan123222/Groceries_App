//
//  CheckoutView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 19/3/25.
//

import SwiftUI

struct CheckoutView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var mainVM: MainViewModel
    let userId: Int
    
    @StateObject var deliveryVM = DeliveryAddressViewModel.shared
    @StateObject var paymentVM = PaymentViewModel.shared
    
    @State private var selectedPaymentMethod = "COD"
    @State private var selectedAddress: AddressModel?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showSuccess = false
    @State private var isOrderAccepted = false
    @State private var orderId: Int?
    @State private var didAddAddress = false
    @State private var showPaymentView = false

    let paymentMethods = ["COD", "MOMO", "PAYPAL"]
// address = AddressModel(street: "123 Main St", wardId: 1, districtId: 2, provinceId: 3), hàm trả về "123 Main St, Ngoc Ha, Ba Dinh, Hanoi".
    private func addressString(for address: AddressModel) -> String {
        let ward = deliveryVM.wardNames[address.wardId] ?? "Unknown"
        let district = deliveryVM.districtNames[address.districtId] ?? "Unknown"
        let province = deliveryVM.provinceNames[address.provinceId] ?? "Unknown"
        return "\(address.street), \(ward), \(district), \(province)"
        /*
         wardId = 1 và deliveryVM.wardNames = [1: "Ngoc Ha"], thì ward = "Ngoc Ha". Nếu không có, ward = "Unknown"
         districtId = 2 và deliveryVM.districtNames = [2: "Ba Dinh"], thì district = "Ba Dinh"
         provinceId = 3 và deliveryVM.provinceNames = [3: "Hanoi"], thì province = "Hanoi"
         */
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text("Checkout")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)

                    Spacer()
                } //. HStack
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)

                Form {
                    Section(header: Text("Delivery Address")) {
                        if deliveryVM.listArr.isEmpty {
                            Text("No addresses available")
                                .foregroundColor(.gray)
                        } else {
                            Picker("Select Address", selection: $selectedAddress) {
                                Text("Select an address").tag(AddressModel?.none)
                                ForEach(deliveryVM.listArr) { address in
                                    Text(addressString(for: address))
                                        .tag(Optional(address))
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        NavigationLink(destination: AddDeliveryAddressView().environmentObject(mainVM)) {// lấy userId
                            Text("Add New Address")
                                .foregroundColor(.blue)
                                .font(.customfont(.medium, fontSize: 16))
                        }
                        .onAppear {
                            if didAddAddress { // gọi api call list sau khi thêm địa chỉ mới
                                deliveryVM.serviceCallList(userId: userId)
                                if let defaultAddress = deliveryVM.listArr.first(where: { $0.isDefault }) { // Tìm địa chỉ mặc định (isDefault = true) trong danh sách địa chỉ
                                    selectedAddress = defaultAddress
                                }
                                didAddAddress = false
                            }
                        }
                        .onDisappear {
                            didAddAddress = true // đánh dấu rằng người dùng đã thêm địa chỉ mới.
                        }
                    } // Section

                    Section(header: Text("Payment Method")) {
                        Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                    }
                } // Form

                Spacer()

                Button(action: {
                    placeOrder()
                }) {
                    Text("Place Order")
                        .font(.customfont(.bold, fontSize: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedAddress == nil ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(selectedAddress == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, .bottomInsets + 20)
            } // VStack
            
            // MOMO, PAYPAL
            NavigationLink(destination: PaymentMethodsView(orderId: orderId ?? 0), isActive: $showPaymentView) {
                EmptyView()
            }

            NavigationLink(destination: OrderAcceptView(orderId: orderId), isActive: $isOrderAccepted) {
                EmptyView()
            }
        }// Zstack
        
        
        .onAppear {
            if userId == 0 {
                errorMessage = "Please log in to place an order."
                showError = true
                return
            }
            deliveryVM.serviceCallList(userId: userId)
            if let defaultAddress = deliveryVM.listArr.first(where: { $0.isDefault }) {
                selectedAddress = defaultAddress
            }
        }
        .onChange(of: paymentVM.isPaymentCompleted) { completed in
            if completed {
                showPaymentView = false
                isOrderAccepted = true // View OrderAcceptView
                successMessage = "Order placed successfully!"
                showSuccess = true
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSuccess) {
            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .top)
    } // body

    func placeOrder() {
        if userId == 0 {
            errorMessage = "Please log in to place an order."
            showError = true
            return
        }

        guard let selectedAddress = selectedAddress else {
            errorMessage = "Please select a delivery address."
            showError = true
            return
        }

        let urlString = "\(Globs.SV_ORDER_PLACE)?paymentProvider=\(selectedPaymentMethod)"
        let params: [String: Any] = [
            "userId": userId,
            "addressId": selectedAddress.id
        ]

        ServiceCall.post(parameter: NSDictionary(dictionary: params), path: urlString) { responseObj in
            print("Response from server: \(responseObj)")
            if let responseDict = responseObj as? NSDictionary {
                if let orderId = responseDict["orderId"] as? Int {
                    self.orderId = orderId
                    if selectedPaymentMethod == "COD" {
                        self.successMessage = "Order placed successfully!"
                        self.showSuccess = true
                        self.isOrderAccepted = true // View OrderAcceptView
                    } else { // MOMO, PAYPAL
                        self.showPaymentView = true
                    }
                } else if let error = responseDict["error"] as? String {
                    self.errorMessage = error
                    self.showError = true
                } else {
                    self.errorMessage = "Failed to retrieve order ID"
                    self.showError = true
                } // if 2
            } // if 1
            else {
                self.errorMessage = "Failed to place order"
                self.showError = true
            }
        } // ServiceCall
        failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Failed to place order"
            self.showError = true
        }
    } // func
} // Struct
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView(userId: 1)
                .environmentObject(MainViewModel.shared)
        }
    }
}
