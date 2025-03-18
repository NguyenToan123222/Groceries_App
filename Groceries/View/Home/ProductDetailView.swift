//
//  ProductDetailView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI
import SDWebImageSwiftUI
        
struct ProductDetailView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var detailVM: ProductDetailViewModel = ProductDetailViewModel(prodObj: ProductModel(dict: [:]) )
    
    var body: some View {
        ZStack{
            
            ScrollView {
                ZStack{
                      Rectangle()
                        .foregroundColor( Color(hex: "F2F2F2") )
                        .frame(width: .screenWidth, height: .screenWidth * 0.8)
                        .cornerRadius(35, corner: [.bottomLeft, .bottomRight])
                    
                    WebImage(url: URL(string: detailVM.pObj.image))

                        .indicator(.activity)
                        // Hiển thị biểu tượng tải ảnh khi ảnh đang tải.
                        .transition(.fade(duration: 0.5))
                         //mở dần khi tải hình ảnh trong 0.5s
                        .scaledToFit()
                        .frame(width: 100, height: 80)

                }
                .frame(width: .screenWidth, height: .screenWidth * 0.8)
                
                VStack{
                    HStack{
                        Text(detailVM.pObj.name)
                            .font(.customfont(.bold, fontSize: 24))
                            .foregroundColor(.primaryText)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            detailVM.serviceCallAddRemoveFav()
                        } label: {
                            
                            Image( detailVM.isFav ? "favorite" : "fav"  )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .foregroundColor(Color.secondaryText)

                    }
                    
                    Text("\(detailVM.pObj.unitValue)\(detailVM.pObj.unitName), Price")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.secondaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        
                        Button {
                            detailVM.addSubQTY(isAdd: false)
                        } label: {
                            
                            Image( "subtack"  )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }
                        
                        Text( "\(detailVM.qty)" )
                            .font(.customfont(.bold, fontSize: 24))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(width: 45, height: 45, alignment: .center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(  Color.placeholder.opacity(0.5), lineWidth: 1)
                            )
                        
                        Button {
                            detailVM.addSubQTY(isAdd: true)
                        } label: {
                            
                            Image( "add_green"  )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }
                        
                        Spacer()
                        
                        Text( "$\(  (detailVM.pObj.offerPrice ?? detailVM.pObj.price) * Double(detailVM.qty) , specifier: "%.2f")"  )
                            .font(.customfont(.bold, fontSize: 28))
                            .foregroundColor(.primaryText)
                            
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                VStack{
                    HStack{
                        Text("Product Detail")
                            .font(.customfont(.semibold, fontSize: 16))
                            .foregroundColor(.primaryText)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        
                        Button {
                            withAnimation {
                                detailVM.ShowDetail()
                            }
                            
                        } label: {
                            
                            Image( detailVM.isShowDetail ? "detail_open" : "next_1"  )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .padding(15)
                        }
                        .foregroundColor(Color.primaryText)

                    }
                    
                    if(detailVM.isShowDetail) {
                        Text(detailVM.pObj.detail)
                            .font(.customfont(.medium, fontSize: 13))
                            .foregroundColor(.secondaryText)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom , 8)
                    }
                    
                    
                    Divider()
                }
                .padding(.horizontal, 20)
                
                
                VStack{
                    HStack{
                        Text("Nutritions")
                            .font(.customfont(.semibold, fontSize: 16))
                            .foregroundColor(.primaryText)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text(detailVM.pObj.nutritionWeight)
                            .font(.customfont(.semibold, fontSize: 10))
                            .foregroundColor(.secondaryText)
                            .padding(8)
                            .background( Color.placeholder.opacity(0.5) )
                            .cornerRadius(5)
                   
                            .foregroundColor(.black)
                        
                        Button {
                            withAnimation {
                                detailVM.ShowNutrition()
                            }
                            
                        } label: {
                            
                            Image( detailVM.isShowNutrition ? "detail_open" : "next_1"  )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .padding(15)
                        }
                        .foregroundColor(Color.primaryText)

                    }
                    
                    if(detailVM.isShowNutrition) {
                        LazyVStack {
                            
                            ForEach( detailVM.nutritionArr , id: \.id) { nObj in
                                HStack{
                                    Text( nObj.nutritionName )
                                        .font(.customfont(.semibold, fontSize: 15))
                                        .foregroundColor(.secondaryText)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    Text( nObj.nutritionValue )
                                        .font(.customfont(.semibold, fontSize: 15))
                                        .foregroundColor(.primaryText)
                                }
                                
                                Divider()
                            }
                            .padding(.vertical, 0)
                           
                            
                        }
                        .padding(.horizontal, 10)
                    }
                    
                    
                    Divider()
                }
                .padding(.horizontal, 20)
                
                HStack{
                    Text("Review")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 2){
                        ForEach( 1...5 , id: \.self) { index in
                            
                            Image(systemName:  "star.fill")
                                .resizable()
                                .scaledToFit()
                                    .foregroundColor( Color.orange)
                                    .frame(width: 15, height: 15)
                                
                        }
                    }
                    
                    Button {
                       
                        
                    } label: {
                        
                        Image( "next_1" )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .padding(15)
                    }
                    .foregroundColor(Color.primaryText)

                }
                .padding(.horizontal, 20)
                
                RoundButton(tittle: "Add To Basket") {
                    CartViewModel.serviceCallAddToCart(prodId: detailVM.pObj.prodId, qty: detailVM.qty) { isDone, msg  in
                        
                        detailVM.qty = 1
                        
                        self.detailVM.errorMessage = msg
                        self.detailVM.showError = true
                    }
                }
                .padding( 20)
                
            }
            
            VStack {
                
                HStack{
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Image("share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }

                }
                
                Spacer()
            }
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)
            
        }
//        .alert(isPresented: $detailVM.showError, content: {
//            
//            Alert(title: Text(Globs.AppName), message: Text(detailVM.errorMessage)  , dismissButton: .default(Text("Ok"))  )
//        })
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(detailVM: ProductDetailViewModel(prodObj: ProductModel(dict: [
            
                "offer_price": 2.49,
                "start_date": "2023-07-30T18:30:00.000Z",
                "end_date": "2023-08-29T18:30:00.000Z",
                "prod_id": 5,
                "cat_id": 1,
                "brand_id": 1,
                "type_id": 1,
                "name": "Organic Banana",
                "detail": "banana, fruit of the genus Musa, of the family Musaceae, one of the most important fruit crops of the world. The banana is grown in the tropics, and, though it is most widely consumed in those regions, it is valued worldwide for its flavour, nutritional value, and availability throughout the year",
                "unit_name": "pcs",
                "unit_value": "7",
                "nutrition_weight": "200g",
                "price": 2.99,
                "image": "data:image/jpeg;base64,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",
                "cat_name": "Frash Fruits & Vegetable",
                "type_name": "Pulses",
                "is_fav": 1
            
        ])))
    }
}
