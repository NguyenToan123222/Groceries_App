//
//  PromoCodeViw.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 18/3/25.
//


import SwiftUI

struct PromoCodeView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @StateObject var promoVM = PromoCodeViewModel.shared
    @State var isPicker: Bool = false
    var didSelect:( (_ obj: PromoCodeModel) -> () )?
    
    var body: some View {
        ZStack{
            
            ScrollView{
                LazyVStack(spacing: 15) {
                    ForEach( promoVM.listArr , id: \.id, content: {
                        pObj in
                        
                            VStack{
                                HStack {
                                    Text(pObj.title)
                                        .font(.customfont(.bold, fontSize: 14))
                                        .foregroundColor(.primaryText)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    
                                    Text(pObj.code)
                                        .font(.customfont(.bold, fontSize: 15))
                                        .foregroundColor(.primaryApp)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.secondaryText.opacity(0.3))
                                        .cornerRadius(5)
                                }
                                
                                Text(pObj.description)
                                    .font(.customfont(.medium, fontSize: 14))
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment( .leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                
                                HStack{
                                    Text("Expiry Date:")
                                        .font(.customfont(.bold, fontSize: 14))
                                        .foregroundColor(.primaryText)
                                        .padding(.vertical, 8)
                                        
                                    
                                    Text( pObj.endDate.displayDate(format: "yyyy-MM-dd hh:mm a") )
                                        .font(.customfont(.bold, fontSize: 12))
                                        .foregroundColor(.secondaryText)
                                        .padding(.vertical, 8)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            } // VStack
                            .padding(15)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(color: Color.black.opacity(0.15), radius: 2)
                            .onTapGesture {
                                if(isPicker) {
                                    mode.wrappedValue.dismiss()
                                    didSelect?(pObj)
                                }
                            }

                    })
                }
                .padding(20)
                .padding(.top, .topInsets + 46)
                .padding(.bottom, .bottomInsets + 60)

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
                    
                    Text("Promo Code")
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
        .onAppear{
            
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}


struct PromoCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PromoCodeView()
            .environmentObject({
                let vm = PromoCodeViewModel()
                vm.listArr = [
                    PromoCodeModel(dict: [
                        "promo_code_id": 1,
                        "title": "Summer Sale",
                        "code": "SUMMER25",
                        "description": "Get 25% off on orders over $50.",
                        "start_date": "2025-07-01 00:00:00",
                        "end_date": "2025-07-31 23:59:59",
                        "type": 1,
                        "min_order_amount": 50.0,
                        "max_discount_amount": 20.0,
                        "offer_price": 0.0
                    ]),
                    PromoCodeModel(dict: [
                        "promo_code_id": 2,
                        "title": "Free Shipping",
                        "code": "FREESHIP",
                        "description": "Free shipping on all orders over $30.",
                        "start_date": "2025-07-05 00:00:00",
                        "end_date": "2025-08-05 23:59:59",
                        "type": 2,
                        "min_order_amount": 30.0,
                        "max_discount_amount": 0.0,
                        "offer_price": 0.0
                    ])
                ]
                return vm
            }())
    }
}
