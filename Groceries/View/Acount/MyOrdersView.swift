//
//  MyOrdersView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.

import SwiftUI
import SDWebImageSwiftUI

struct MyOrdersView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var myVM = MyOrdersViewModel.shared
    @State private var searchText = ""

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(myVM.listArr, id: \.id) { myObj in
                        NavigationLink {
                            MyOrdersDetailView(detailVM: MyOrderDetailViewModel(prodObj: myObj))
                        } label: {
                            VStack {
                                HStack {
                                    Text("Order Code: ")
                                        .font(.customfont(.bold, fontSize: 16))
                                        .foregroundColor(.primaryText)

                                    Text(myObj.orderCode)
                                        .font(.customfont(.bold, fontSize: 14))
                                        .foregroundColor(.primaryText)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                                    Text(myObj.status)
                                        .font(.customfont(.bold, fontSize: 16))
                                        .foregroundColor(getOrderStatusColor(mObj: myObj))
                                }

                                Text(myObj.createdDate.displayDate(format: "yyyy-MM-dd hh:mm a"))
                                    .font(.customfont(.bold, fontSize: 12))
                                    .foregroundColor(.secondaryText)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                                HStack {
                                    if let firstItem = myObj.items.first, let imageUrl = firstItem.imageUrl {
                                        // lấy phần tử đầu tiên trong mảng (not nil)
                                        // lấy img từ phần tử mảng đó
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

                                    VStack {
                                        HStack {
                                            Text("Items:")
                                                .font(.customfont(.bold, fontSize: 16))
                                                .foregroundColor(.primaryText)

                                            Text(myObj.items.map { $0.productName }.joined(separator: ", "))
                                            // Apple, Orange, Milk
                                                .font(.customfont(.medium, fontSize: 14))
                                                .foregroundColor(.secondaryText)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        }

                                        HStack {
                                            Text("Payment Method:")
                                                .font(.customfont(.bold, fontSize: 16))
                                                .foregroundColor(.primaryText)

                                            Text(myObj.paymentMethod)
                                                .font(.customfont(.medium, fontSize: 14))
                                                .foregroundColor(.secondaryText)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        }

                                        HStack {
                                            Text("Payment Status:")
                                                .font(.customfont(.bold, fontSize: 16))
                                                .foregroundColor(.primaryText)

                                            Text(myObj.isPaid ? "Paid" : "Unpaid")
                                                .font(.customfont(.medium, fontSize: 14))
                                                .foregroundColor(myObj.isPaid ? .green : .red)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                } // H 2
                            } // Vstack
                            .padding(15)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(color: Color.black.opacity(0.15), radius: 2)
                            .onAppear {
                                myVM.loadMoreIfNeeded(currentItem: myObj)
                            }
                        } // Label
                    } // For

                    if myVM.isLoadingMore {
                        ProgressView()
                            .padding()
                    }
                } // LazyStack
                .padding(20)
                .padding(.top, .topInsets + 46)
                .padding(.bottom, .bottomInsets + 60)
            } // Scroll

            VStack {
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }

                    Spacer()

                    Text("My Orders")
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(height: 46)

                    Spacer()
                }// Hstack
                
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)

                Spacer()
            } // Vstack
            
        } // Zstack
        .onAppear {
            myVM.refreshOrders() // Làm mới danh sách khi view xuất hiện
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }

    func getOrderStatusColor(mObj: MyOrderModel) -> Color {
        switch mObj.status {
        case "PENDING":
            return Color.blue
        case "COMPLETED":
            return Color.green
        case "CANCELLED":
            return Color.red
        case "AWAITING_PICKUP":
            return Color.orange
        default:
            return Color.gray
        }
    }
}

struct MyOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyOrdersView()
        }
    }
}

/*
 
 {
   "content": [
     {
       "id": 1,
       "orderCode": "ORD001",
       "totalPrice": 150.75,
       "status": "PENDING",
       "paymentMethod": "MOMO",
       "isPaid": false,
       "createdAt": "2025-03-20T10:30:00Z",
       "items": [
         {
           "id": 101,
           "productId": "P101",
           "productName": "Apple",
           "imageUrl": "https://example.com/images/apple.jpg",
           "quantity": 2,
           "unitPrice": 2.50
         },
         {
           "id": 102,
           "productId": "P102",
           "productName": "Orange Juice",
           "imageUrl": "https://example.com/images/orange_juice.jpg",
           "quantity": 1,
           "unitPrice": 3.25
         }
       ],
       "street": "123 Main Street",
       "province": "Hanoi",
       "district": "Ba Dinh",
       "ward": "Ngoc Ha"
     },
     {
       "id": 2,
       "orderCode": "ORD002",
       "totalPrice": 89.99,
       "status": "COMPLETED",
       "paymentMethod": "COD",
       "isPaid": true,
       "createdAt": "2025-03-19T15:45:00Z",
       "items": [
         {
           "id": 103,
           "productId": "P103",
           "productName": "Milk",
           "imageUrl": "https://example.com/images/milk.jpg",
           "quantity": 3,
           "unitPrice": 1.99
         }
       ],
       "street": "456 Elm Street",
       "province": "Ho Chi Minh City",
       "district": "District 1",
       "ward": "Ben Nghe"
     },
     {
       "id": 3,
       "orderCode": "ORD003",
       "totalPrice": 200.00,
       "status": "AWAITING_PICKUP",
       "paymentMethod": "PAYPAL",
       "isPaid": true,
       "createdAt": "2025-03-18T09:15:00Z",
       "items": [
         {
           "id": 104,
           "productId": "P104",
           "productName": "Bread",
           "imageUrl": "https://example.com/images/bread.jpg",
           "quantity": 1,
           "unitPrice": 2.00
         }
       ],
       "street": "789 Oak Street",
       "province": "Da Nang",
       "district": "Hai Chau",
       "ward": "Thanh Binh"
     }
   ],
   "pageable": {
     "pageNumber": 0,
     "pageSize": 5,
     "sort": {
       "sorted": true,
       "unsorted": false,
       "empty": false
     },
     "offset": 0,
     "paged": true,
     "unpaged": false
   },
   "totalPages": 1,
   "totalElements": 3,
   "last": true,
   "numberOfElements": 3,
   "size": 5,
   "number": 0,
   "sort": {
     "sorted": true,
     "unsorted": false,
     "empty": false
   },
   "first": true,
   "empty": false
 }
 
 */
