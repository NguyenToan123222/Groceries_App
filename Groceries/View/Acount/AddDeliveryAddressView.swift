//
//  AddDeliveryAddressView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 17/3/25.


import SwiftUI

struct AddDeliveryAddressView: View {
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    @StateObject var addressVM = DeliveryAddressViewModel.shared
    @State var isEdit: Bool = false
    @State var editObj: AddressModel?
    
    var body: some View {
        ZStack {
            
            ScrollView{
                VStack(spacing: 15){
                    
                    HStack{
                        
                        Button {
                            addressVM.txtTypeName = "Home"
                        } label: {
                            Image(systemName: addressVM.txtTypeName == "Home" ? "record.circle" : "circle"  )
                                
                            Text("Home")
                                .font(.customfont(.medium, fontSize: 16))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(.primaryText)
                        
                        Button {
                            addressVM.txtTypeName = "Office"
                        } label: {
                            Image(systemName: addressVM.txtTypeName == "Office" ? "record.circle" : "circle"  )
                                
                            Text("Office")
                                .font(.customfont(.medium, fontSize: 16))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading )
                        }
                        .foregroundColor(.primaryText)
                        
                        
                    }
                    // HStack
                    
                    LineTextField(txt: $addressVM.txtName, title: "Name", placeholder: "Enter you name")
                    
                    LineTextField(txt: $addressVM.txtMobile, title: "Mobile", placeholder: "Enter you mobile number", keyboardType: .numberPad)
                    
                    LineTextField(txt: $addressVM.txtAddress, title: "Address Line", placeholder: "Enter you address")
                    
                    HStack{
                        LineTextField(txt: $addressVM.txtCity, title: "City", placeholder: "Enter you city")
                        LineTextField(txt: $addressVM.txtState, title: "State", placeholder: "Enter you state")
                    }
                   
                    
                    LineTextField(txt: $addressVM.txtPostalCode, title: "Postal Code", placeholder: "Enter you postal code")
                    
                    RoundButton(tittle: isEdit ? "Update Address" : "Add Address") {
                        if(isEdit) { // Update
                            addressVM.serviceCallUpdateAddress(aObj: editObj) {
                                self.mode.wrappedValue.dismiss() // Sau khi cập nhật thành công. đóng màn hình.
                            }
                        } else { // Add
                            addressVM.serviceCallAddAddress {
                                self.mode.wrappedValue.dismiss() // Sau khi cập nhật thành công. đóng màn hình.
                            }
                        }
                    }
                    
                }
                .padding(20)
                .padding(.top, .topInsets + 46)

            }
            
            VStack {
                    
                HStack{
                    
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }

                    
                   
                    Spacer()
                    
                    Text( isEdit ? "Edit Delivery Address" : "Add Delivery Address")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)
                    Spacer()
                    
                    

                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.2),  radius: 2 )
                
                Spacer()
                
            }
        }
        .onAppear{// thực hiện khi edit và đưa dữ liệu từ : DeliveryAddressView sang AddDeliveryAddressView
            if(isEdit) {
                if let aObj = editObj {
                    addressVM.setData(aObj: aObj)
                }
            }
        }
//        .alert(isPresented: $addressVM.showError) {
//            Alert(title: Text(Globs.AppName), message: Text(addressVM.errorMessage), dismissButton: .default(Text("Ok")))
//        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

struct AddDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeliveryAddressView()
    }
}
