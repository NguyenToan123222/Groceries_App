////
////  CheckoutView.swift
////  Groceries
////
////  Created by Nguyễn Toàn on 19/3/25.
//
//import SwiftUI
//
//struct CheckoutView: View {
//    
//    @Binding var isShow: Bool
//    @StateObject var cartVM = CartViewModel.shared
//    
//    
//    
//    var body: some View {
//        VStack { // 1
//            
//            Spacer()
//            VStack{ // 2
//                HStack{
//                    
//                    Text("Checkout")
//                        .font(.customfont(.bold, fontSize: 20))
//                        .frame(height: 46)
//                    Spacer()
//                    
//                    Button {
//                        $isShow.wrappedValue = false
//                    } label: {
//                        Image("close")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                    }
//                    
//                    
//                } // Hstack
//                .padding(.top, 30)
//                
//                Divider()
//                
//                
//                VStack{
////                    HStack {
////                        Text("Delivery Type")
////                            .font(.customfont(.semibold, fontSize: 18))
////                            .foregroundColor(.secondaryText)
////                            .frame(height: 46)
////                        
////                        Spacer()
////                        
////                        Picker("",  selection: $cartVM.deliveryType) {
////                            Text("Delivery").tag(1)
////                            Text("Collection").tag(2)
////                        }
////                        .pickerStyle(.segmented)
////                        .frame(width: 180)
////                    }
//                    
//                    Divider()
//                    
////                    if(cartVM.deliveryType == 1) {
////                        
////                        NavigationLink {
////                            DeliveryAddressView(isPicker: true, didSelect: {
////                                aObj in
////                                cartVM.deliverObj = aObj // gán data khi user chọn
////                            // Chọn "Home" sẽ gán deliverObj = Address(name: "Home", street: "123 Main St").
////                            } )
////                        } label: {
////                            HStack {
////                                Text("Delivery")
////                                    .font(.customfont(.semibold, fontSize: 18))
////                                    .foregroundColor(.secondaryText)
////                                    .frame(height: 46)
////                                
////                                Spacer()
////                                
////                                Text( cartVM.deliverObj?.name ?? "Select Method")
////                                    .font(.customfont(.semibold, fontSize: 18))
////                                    .foregroundColor(.primaryText)
////                                    .frame(height: 46)
////                                
////                                Image("next_1")
////                                    .resizable()
////                                    .scaledToFit()
////                                    .frame(width: 20, height: 20)
////                                    .foregroundColor(.primaryText)
////                            }
////                        }
////                        Divider()
////                    }
//                    
//                    
//                    HStack {
//                        Text("Payment Type")
//                            .font(.customfont(.semibold, fontSize: 18))
//                            .foregroundColor(.secondaryText)
//                            .frame(height: 46)
//                        
//                        Spacer()
//                        
////                        Picker("",  selection: $cartVM.paymentType) {
////                            Text("COD").tag(1)
////                            Text("Online").tag(2)
////                        }
////                        .pickerStyle(.segmented)
////                        .frame(width: 150)
//                    }
//                    
//                    Divider()
//                    if(cartVM.paymentType == 2) {
//                        
//                        NavigationLink {
//                            PaymentMethodsView(isPicker: true, didSelect: {
//                                pObj in
//                                cartVM.paymentObj = pObj // gán data khi user chọn
//                                // Chọn "1234-5678" sẽ gán paymentObj = PaymentMethod(cardNumber: "1234-5678", type: "MasterCard").
//                            } )
//                        } label: {
//                            HStack {
//                                Text("Payment")
//                                    .font(.customfont(.semibold, fontSize: 18))
//                                    .foregroundColor(.secondaryText)
//                                    .frame(height: 46)
//                                
//                                Spacer()
//                                
//                                Image("master")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 30, height: 20)
//                                
//                                Text( cartVM.paymentObj?.cardNumber ?? "Select")
//                                    .font(.customfont(.semibold, fontSize: 18))
//                                    .foregroundColor(.primaryText)
//                                    .frame(height: 46)
//                                
//                                Image("next_1")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 20, height: 20)
//                                    .foregroundColor(.primaryText)
//                                
//                            }
//                        }
//                        
//                        Divider()
//                    }
//                    
//                    NavigationLink {
//                        PromoCodeView(isPicker: true, didSelect: {
//                            pObj in
//                            cartVM.promoObj = pObj // gán data khi user chọn
//                            // Chọn "SAVE10" sẽ gán promoObj = PromoCode(code: "SAVE10", discount: 10.0).
//                        })
//                    } label: {
//                        HStack {
//                            Text("Promo Code")
//                                .font(.customfont(.semibold, fontSize: 18))
//                                .foregroundColor(.secondaryText)
//                                .frame(height: 46)
//                            
//                            Spacer()
//                            
//                            
//                            
//                            Text( cartVM.promoObj?.code  ?? "Pick Discount")
//                                .font(.customfont(.semibold, fontSize: 18))
//                                .foregroundColor(.primaryText)
//                                .frame(height: 46)
//                            
//                            Image("next_1")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.primaryText)
//                            
//                        }
//                    }
//                    
//                    Divider()
//                }
//                
//                VStack{
//                    HStack {
//                        Text("Totat")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.secondaryText)
//                        
//                        Spacer()
//                        
//                        Text("$ \(cartVM.total)")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.secondaryText)
//                    }
//                    
//                    HStack {
//                        Text("Delivery Cost")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.secondaryText)
//                        
//                        Spacer()
//                        
//                        Text("+ $ \(cartVM.deliverPriceAmount)")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.secondaryText)
//                    }
//                    
//                    HStack {
//                        Text("Discount")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.secondaryText)
//                        
//                        Spacer()
//                        
//                        Text("- $ \(cartVM.discountAmount)")
//                            .font(.customfont(.semibold, fontSize: 16))
//                            .foregroundColor(.red)
//                    }
//                    
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 15)
//                
//                HStack {
//                    Text("Final Total")
//                        .font(.customfont(.semibold, fontSize: 18))
//                        .foregroundColor(.secondaryText)
//                        .frame(height: 46)
//                    
//                    Spacer()
//                    
//                    
//                    
//                    Text("$\(cartVM.userPayAmount)")
//                        .font(.customfont(.semibold, fontSize: 18))
//                        .foregroundColor(.primaryText)
//                        .frame(height: 46)
//                    
//                    Image("next")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.primaryText)
//                    
//                }
//                Divider()
//                
//                VStack {
//                    Text("By continuing you agree to our")
//                        .font(.customfont(.semibold, fontSize: 14))
//                        .foregroundColor(.secondaryText)
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                    
//                    HStack{
//                        
//                        Text("Terms of Service")
//                            .font(.customfont(.semibold, fontSize: 14))
//                            .foregroundColor(.primaryText)
//                        
//                        
//                        Text(" and ")
//                            .font(.customfont(.semibold, fontSize: 14))
//                            .foregroundColor(.secondaryText)
//                        
//                        
//                        Text("Privacy Policy.")
//                            .font(.customfont(.semibold, fontSize: 14))
//                            .foregroundColor(.primaryText)
//                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                        
//                    }
//                    
//                }
//                .padding(.vertical, .screenWidth * 0.03)
//                
//                RoundButton(tittle: "Place Order") {
//                    cartVM.serviceCallOrderPlace()
//                }
//                .padding(.bottom, .bottomInsets + 70)
//            } // Vstack 2
//            .padding(.horizontal, 20)
//            .background(Color.white)
//            .cornerRadius(20, corner: [.topLeft, .topRight])
//        }
//    }
//}
//
//struct CheckoutView_Previews: PreviewProvider {
//    @State static var isShow: Bool = false;
//    static var previews: some View {
//        NavigationView {
//            CheckoutView(isShow: $isShow)
//        }
//        
//    }
//}
