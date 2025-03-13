//
//  FavouriteView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteView: View {
    
    @StateObject var favVM = FavouriteViewModel.shared
    
    var body: some View {
        ZStack{
            
            ScrollView{ // bị đè bởi Vstack
                LazyVStack {
                    ForEach( favVM.listArr , id: \.id, content: {
                        fObj in
                        
                        FavouriteRow(fObj: fObj)
                        
                    })
                }
                .padding(20)
                .padding(.top, .topInsets + 46)
                .padding(.bottom, .bottomInsets + 60)
            
            }
            
            VStack {
                    
                HStack{
                   
                    Spacer()
                    
                    Text("Favorites")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)
                    Spacer()

                }
                .padding(.top, .topInsets)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.2),  radius: 2 )
                
                Spacer()
                
                
                RoundButton(tittle: "Add All To Cart")
                    .padding(.horizontal, 20)
                    .padding(.bottom, .bottomInsets + 80)
                
            }
            
            
            
            
        }
        .onAppear{
            // favVM.serviceCallList
        }
        .ignoresSafeArea()
    }
}

struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProducts = [
            ProductModel(dict: [
                "prod_id": 1,
                "name": "Organic Apple",
                "detail": "Fresh organic apples, rich in vitamins.",
                "unit_name": "kg",
                "unit_value": "1",
                "nutrition_weight": "250g",
                "price": 3.99,
                "offer_price": 2.99,
                "image": "https://t4.ftcdn.net/jpg/04/96/45/49/360_F_496454926_VsM8D2yyMDFzAm8kGCNFd7vkKpt7drrK.jpg",
                "cat_name": "Fresh Fruits",
                "type_name": "Fruit",
                "is_fav": 1
            ]),
            ProductModel(dict: [
                "prod_id": 2,
                "name": "Carrot",
                "detail": "Crunchy and nutritious carrots.",
                "unit_name": "kg",
                "unit_value": "2",
                "nutrition_weight": "300g",
                "price": 2.49,
                "offer_price": 1.99,
                "image": "https://media.istockphoto.com/id/1388403435/photo/fresh-carrots-isolated-on-white-background.jpg?s=612x612&w=0&k=20&c=XmrTb_nASc7d-4zVKUz0leeTT4fibDzWi_GpIun0Tlc=",
                "cat_name": "Vegetables",
                "type_name": "Root Vegetable",
                "is_fav": 0
            ]),
            ProductModel(dict: [
                "prod_id": 3,
                "name": "Fresh Milk",
                "detail": "Organic whole milk, rich in calcium.",
                "unit_name": "L",
                "unit_value": "1",
                "nutrition_weight": "1L",
                "price": 4.99,
                "offer_price": 3.99,
                "image": "https://img.freepik.com/free-vector/realistic-vector-icon-illustration-dairy-farm-fresh-milk-splash-with-milk-jug-bottle-isola_134830-2399.jpg?semt=ais_hybrid",
                "cat_name": "Dairy",
                "type_name": "Milk",
                "is_fav": 1
            ]),
            ProductModel(dict: [
                "prod_id": 4,
                "name": "Whole Wheat Bread",
                "detail": "Healthy whole wheat bread.",
                "unit_name": "pcs",
                "unit_value": "1",
                "nutrition_weight": "500g",
                "price": 2.99,
                "offer_price": 2.49,
                "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgkeYnkvGnkSzX16RireD06ZhVdjT1EZ6FUg&s",
                "cat_name": "Bakery",
                "type_name": "Bread",
                "is_fav": 0
            ])
        ]
        
        let favVM = FavouriteViewModel.shared
        favVM.listArr = sampleProducts
        
        return FavouriteView()
            .environmentObject(favVM)
    }
}
