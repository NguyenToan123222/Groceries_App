//
//  FavouriteRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteRow: View {
    @State var fObj: ProductModel
    @StateObject var cartVM = CartViewModel.shared
    @StateObject var favoriteVM = FavouriteViewModel.shared
    var onDelete: (Int) -> Void
    var onAddToCart: (Int) -> Void
    @State private var isImageLoaded = false
    @State private var hasImageFailed = false

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                
                    // Main product image
                WebImage(url: URL(string: fObj.imageUrl ?? "https://img.freepik.com/free-vector/illustration-gallery-icon_53876-27002.jpg"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                
                VStack(spacing: 4) {
                    Text(fObj.name)
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.primaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(fObj.unitValue.isEmpty ? "" : fObj.unitValue + " ")\(fObj.unitName.isEmpty ? "" : fObj.unitName)\(fObj.unitValue.isEmpty && fObj.unitName.isEmpty ? "" : ", price")")
                        .font(.customfont(.medium, fontSize: 14))
                        .foregroundColor(.secondaryText)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                
                Text("$\(fObj.offerPrice ?? fObj.price, specifier: "%.2f")")
                    .font(.customfont(.semibold, fontSize: 18))
                    .foregroundColor(.primaryText)
                
                Button(action: {
                    onAddToCart(fObj.id)
                }) {
                    Image(systemName: "cart.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    onDelete(fObj.id)
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                
                NavigationLink(destination: ProductDetailView(productId: fObj.id)) {
                    Image("next_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
        }
        .onAppear {
            isImageLoaded = false
            hasImageFailed = false
        }
    }
}

struct FavouriteRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavouriteRow(
                fObj: ProductModel(dict: [
                    "id": 1,
                    "name": "Organic Apple",
                    "detail": "Fresh organic apples, rich in vitamins.",
                    "unitName": "kg",
                    "unitValue": "4",
                    "nutrition_weight": "250g",
                    "price": 3.99,
                    "offerPrice": 2.9,
                    "imageUrl": "https://t4.ftcdn.net/jpg/04/96/45/49/360_F_496454926_VsM8D2yyMDFzAm8kGCNFd7vkKpt7drrK.jpg",
                    "category": "Fresh Fruits",
                    "brand": "Fruit",
                    "is_fav": 1
                ]),
                onDelete: { productId in
                    print("Deleted product with ID: \(productId)")
                },
                onAddToCart: { productId in
                    print("Added product with ID: \(productId) to cart")
                }
            )
        }
    }
}
