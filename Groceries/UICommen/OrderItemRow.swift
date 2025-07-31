//
//  OrderItemRow.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.


import SwiftUI
import SDWebImageSwiftUI

struct OrderItemRow: View {
    let pObj: OrderItemModel
    // pObj = OrderItemModel(productName: "Organic Banana", quantity: 2, price: 1.5, imageUrl: "https://example.com/banana.jpg")
    let showReviewButton: Bool
    let onReview: () -> Void
    var rating: Float?
    
    init(pObj: OrderItemModel, showReviewButton: Bool = false, onReview: @escaping () -> Void = {}, rating: Float? = nil) {
        self.pObj = pObj
        self.showReviewButton = showReviewButton
        self.onReview = onReview
        self.rating = rating// OrderItemRow(pObj: item, showReviewButton: true, onReview: { print("Review") }, rating: 4.0)
    }

    var body: some View {
        HStack {
            if let imageUrl = pObj.imageUrl {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(pObj.productName)
                    .font(.customfont(.bold, fontSize: 16))
                    .foregroundColor(.primaryText)

                Text("Qty: \(pObj.quantity)")
                    .font(.customfont(.regular, fontSize: 14))
                    .foregroundColor(.secondaryText)

                Text("Price: $ \(pObj.price, specifier: "%.2f")")
                    .font(.customfont(.bold, fontSize: 14))
                    .foregroundColor(.primaryText)

                if let ratingValue = rating, ratingValue > 0 {
                    HStack {
                        Text("Your Rating:")
                            .font(.customfont(.regular, fontSize: 14))
                            .foregroundColor(.secondaryText)
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(index <= Int(ratingValue) ? .orange : .gray)
                        }
                    }
                }
            }

            Spacer()

            if showReviewButton {
                Button(action: onReview) {
                    Text("Write Review")
                        .font(.customfont(.bold, fontSize: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .cornerRadius(5)
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.15), radius: 2)
        .padding(.horizontal, 20)
    }
}

struct OrderItemRow_Previews: PreviewProvider {
    static var previews: some View {
        OrderItemRow(
            pObj: OrderItemModel(dict: [
                "productId": 1,
                "productName": "Organic Banana",
                "quantity": 2,
                "price": 1.5,
                "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
                "rating": 5
            ]),
            showReviewButton: true,
            onReview: {}
        )
    }
}
