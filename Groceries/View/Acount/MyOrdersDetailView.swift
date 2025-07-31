//
//  MyOrdersDetailView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 20/3/25.
// MyOrdersDetailView.swift
import SwiftUI
import SDWebImageSwiftUI

struct MyOrdersDetailView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @StateObject var detailVM: MyOrderDetailViewModel
    @StateObject var reviewVM = ReviewViewModel.shared
    
    @State private var selectedItem: OrderItemModel?
    
    @State private var selectedRating: Float = 0.0
    @State private var selectedComment: String = "" // Thêm biến để lưu comment

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Order Code: \(detailVM.pObj.orderCode)")
                            .font(.customfont(.bold, fontSize: 20))
                            .foregroundColor(.primaryText)

                        Spacer()

                        Text(detailVM.pObj.isPaid ? "Paid" : "Unpaid")
                            .font(.customfont(.bold, fontSize: 18))
                            .foregroundColor(detailVM.pObj.isPaid ? .green : .red)
                    } // Hstack

                    HStack {
                        Text(detailVM.pObj.createdDate.displayDate(format: "yyyy-MM-dd hh:mm a"))
                            .font(.customfont(.regular, fontSize: 12))
                            .foregroundColor(.secondaryText)

                        Spacer()

                        Text(detailVM.pObj.status)
                            .font(.customfont(.bold, fontSize: 18))
                            .foregroundColor(getOrderStatusColor(mObj: detailVM.pObj))
                    } // Hstack
                    .padding(.bottom, 8)

                    Text("\(detailVM.pObj.street), \(detailVM.pObj.ward), \(detailVM.pObj.district), \(detailVM.pObj.province)")
                        .font(.customfont(.regular, fontSize: 16))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    HStack {
                        Text("Payment Method:")
                            .font(.customfont(.medium, fontSize: 16))
                            .foregroundColor(.primaryText)

                        Spacer()

                        Text(detailVM.pObj.paymentMethod)
                            .font(.customfont(.regular, fontSize: 16))
                            .foregroundColor(.primaryText)
                    }
                    .padding(.bottom, 4)

                    if detailVM.pObj.status == "PENDING" {
                        Button(action: {
                            detailVM.cancelOrder()
                        }) {
                            Text("Cancel Order")
                                .font(.customfont(.bold, fontSize: 16))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    
                } // Vstack
                .padding(15)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(color: Color.black.opacity(0.15), radius: 2)
                .padding(.horizontal, 20)
                .padding(.top, .topInsets + 46)

                
                
                LazyVStack {
                    ForEach(detailVM.listArr, id: \.id) { pObj in
                        OrderItemRow(
                            pObj: pObj,
                            showReviewButton: detailVM.pObj.status == "COMPLETED" && pObj.rating == 0,
                            onReview: {
                                selectedItem = pObj
                                selectedRating = 0.0
                                selectedComment = "" // Reset comment khi mở sheet
                            }
                        )
                    }
                }
                
                

                VStack {
                    HStack {
                        Text("Total:")
                            .font(.customfont(.bold, fontSize: 22))
                            .foregroundColor(.primaryText)

                        Spacer()

                        Text("$ \(detailVM.pObj.totalPrice, specifier: "%.2f")")
                            .font(.customfont(.bold, fontSize: 22))
                            .foregroundColor(.primaryText)
                    }
                    .padding(.bottom, 4)
                }
                .padding(15)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(color: Color.black.opacity(0.15), radius: 2)
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            } // Scroll

            VStack {
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text("My Order Detail")
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.primaryText)

                    Spacer()
                }
                Spacer() // Vertical Bottom
            } // Vstack
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)
            
            
        } // Zstack
        .alert(isPresented: $detailVM.showError) {
            Alert(title: Text("Error"), message: Text(detailVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        /*
         Ví dụ: Giả sử bạn có một nút "Viết đánh giá" trong ứng dụng. Khi người dùng nhấn nút đó, bạn gán selectedItem = Product(id: "123", productId: "P123"). Điều này khiến sheet bật lên để người dùng nhập đánh giá.
         */
        .sheet(isPresented: Binding(
            get: { selectedItem != nil },
            set: { if !$0 { selectedItem = nil } } // Nếu giá trị mới ($0) là false (tức là sheet bị đóng), thì đặt selectedItem = nil để reset trạng thái.
            /*
             get: { selectedItem != nil }: Phần get xác định giá trị của Binding<Bool>. Nếu selectedItem không phải nil, thì trả về true (sheet hiển thị). Nếu selectedItem là nil, trả về false (sheet không hiển thị).
             set: { if !$0 { selectedItem = nil } }: Phần set được gọi khi trạng thái của sheet thay đổi (ví dụ, khi người dùng đóng sheet). Nếu giá trị mới ($0) là false (tức là sheet bị đóng), thì đặt selectedItem = nil để reset trạng thái.
             
             Ban đầu, selectedItem = nil, nên get trả về false, sheet không hiển thị.
             Khi người dùng chọn một sản phẩm (ví dụ, selectedItem = Product(id: "123", productId: "P123")), get trả về true, sheet bật lên.
             Khi người dùng đóng sheet (bằng cách vuốt xuống hoặc nhấn hủy), set được gọi với $0 = false, khiến selectedItem được đặt lại thành nil.
             */
        )) {
            /*
             Giả sử selectedItem = Product(id: "123", productId: "P123").
             Câu lệnh này sẽ gán item = Product(id: "123", productId: "P123"), và code bên trong block sẽ chạy. Nếu selectedItem = nil, block sẽ bị bỏ qua.
             */
            if let item = selectedItem { // kiểm tra xem selectedItem có giá trị hay không.
                WriteReviewView(
                    rating: $selectedRating, // Giả sử selectedRating = 3. Trong WriteReviewView, người dùng thay đổi thành 4 sao, thì selectedRating sẽ được cập nhật thành 4.
                    comment: $selectedComment, // Giả sử selectedComment = "". Người dùng nhập "Sản phẩm rất tốt" trong WriteReviewView, thì selectedComment sẽ được cập nhật thành "Sản phẩm rất tốt".
                    onSubmit: {
                        reviewVM.addReview(
                            productId: item.productId,
                            rating: selectedRating, // Nếu người dùng chọn 4 sao, thì selectedRating = 4 sẽ được truyền vào.
                            comment: selectedComment.isEmpty ? nil : selectedComment
                        ) { success, message in // success = true, message = "Đánh giá đã được gửi"
                            if success {
                                // Cập nhật rating trong listArr
                                detailVM.listArr = detailVM.listArr.map { p in // listArr = [Product(id: "123", rating: 0), Product(id: "456", rating: 3)]
                                    var updatedItem = p // p = Product(id: "123", rating: 0)
                                    if p.id == item.id {
                                        updatedItem.rating = selectedRating //Cập nhật thuộc tính rating của updatedItem. Nếu selectedRating = 4, thì updatedItem.rating được cập nhật thành 4
                                    }
                                    return updatedItem // p.id = "123", thì updatedItem có rating = 4. Nếu p.id = "456", thì updatedItem giữ nguyên rating = 3
                                }
                                // Cập nhật lại trạng thái showReviewButton
                                reviewVM.canUserReview(productId: item.productId) { can in
                                    if !can {
                                        print("User can no longer review product \(item.productId)")
                                    }
                                }
                            }
                            reviewVM.errorMessage = message
                            reviewVM.showError = true
                            selectedItem = nil
                        } // api
                    },
                    onCancel: {
                        selectedItem = nil
                    }
                )
            }
        }
        .alert(isPresented: $reviewVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(reviewVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
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

struct MyOrdersDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyOrdersDetailView(detailVM: MyOrderDetailViewModel(prodObj: MyOrderModel(dict: [
                "id": 4,
                "orderCode": "ORD-123456789",
                "totalPrice": 10.45,
                "status": "PENDING",
                "paymentMethod": "MOMO",
                "isPaid": false,
                "createdAt": "2025-07-10T19:00:00Z", // Thêm createdAt hợp lệ
                "items": [
                    ["productId": 1, "productName": "Organic Banana", "quantity": 2, "price": 1.5, "imageUrl": "https://example.com/banana.jpg", "rating": 0.0],
                    ["productId": 2, "productName": "Red Apple", "quantity": 1, "price": 2.0, "imageUrl": "https://example.com/apple.jpg", "rating": 4.0]
                ],
                "street": "246/ A",
                "province": "Hồ Chí Minh",
                "district": "Quận 1",
                "ward": "Phường Bến Nghé"
            ])))
            .environmentObject(MainViewModel.shared) // Thêm environment object
        }
    }
}
/*
 {
   "id": 1001,
   "orderCode": "ORD-20250710-001",
   "totalPrice": 75.50,
   "status": "COMPLETED",
   "paymentMethod": "MOMO",
   "isPaid": true,
   "createdAt": "2025-07-10T21:00:00Z",
   "items": [
     {
       "productId": 101,
       "productName": "Organic Banana",
       "quantity": 5,
       "price": 1.50,
       "imageUrl": "https://example.com/banana.jpg",
       "rating": 4.5
     },
     {
       "productId": 102,
       "productName": "Fresh Orange",
       "quantity": 3,
       "price": 2.00,
       "imageUrl": "https://example.com/orange.jpg",
       "rating": 0.0
     }
   ],
   "street": "456 Đường Lê Lợi",
   "province": "TP.HCM",
   "district": "Quận 3",
   "ward": "Phường 14"
 }
 
 */
