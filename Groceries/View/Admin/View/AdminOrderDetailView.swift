//
//  AdminOrderDetailView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 16/4/25.
// AdminOrderDetailView.swift
import SwiftUI
import SDWebImageSwiftUI

struct AdminOrderDetailView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var detailVM: AdminOrderDetailViewModel
    @State private var selectedStatus: String = ""

    var body: some View {
        ZStack {
            ScrollView {
                orderInfoSection
                orderItemsSection
                totalSection
            }
            headerSection
        }
        .alert(isPresented: $detailVM.showError) {
            Alert(title: Text("Error"), message: Text(detailVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $detailVM.showSuccess) {
            Alert(title: Text("Success"), message: Text(detailVM.successMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    } // body

    private var orderInfoSection: some View {
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
            }// Hstack
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
            }// Hstack
            .padding(.bottom, 4)

            // Chỉ hiển thị nút "Complete COD Payment" nếu đơn hàng là COD, trạng thái AWAITING_PICKUP và chưa thanh toán
            if detailVM.pObj.paymentMethod == "COD" && detailVM.pObj.status == "AWAITING_PICKUP" && !detailVM.pObj.isPaid {
                Button(action: {
                    detailVM.completeCODPayment()
                }) {
                    Text("Complete COD Payment")
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        } // VStack
        .padding(15)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.15), radius: 2)
        .padding(.horizontal, 20)
        .padding(.top, .topInsets + 46)
    }

    private var orderItemsSection: some View {
        LazyVStack {
            ForEach(detailVM.listArr, id: \.id) { pObj in
                OrderItemRow(pObj: pObj)
            }
        } // Lazy
    }

    private var totalSection: some View {
        VStack {
            HStack {
                Text("Total:")
                    .font(.customfont(.bold, fontSize: 22))
                    .foregroundColor(.primaryText)

                Spacer()

                Text("$ \(detailVM.pObj.totalPrice, specifier: "%.2f")")
                    .font(.customfont(.bold, fontSize: 22))
                    .foregroundColor(.primaryText)
            } // Hstack
            .padding(.bottom, 4)
        } // Vstack
        .padding(15)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.15), radius: 2)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }

    private var headerSection: some View {
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

                Text("Order Detail")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.primaryText)

                Spacer()
            } // Hstack
            Spacer()
        } // Vstack
        .padding(.top, .topInsets)
        .padding(.horizontal, 20)
    }

    private func getOrderStatusColor(mObj: MyOrderModel) -> Color {
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
} // View

struct AdminOrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AdminOrderDetailView(detailVM: AdminOrderDetailViewModel(prodObj: MyOrderModel(dict: [
            "id": 4,
            "orderCode": "ORD-123456789",
            "totalPrice": 10.45,
            "status": "PENDING",
            "paymentMethod": "COD",
            "isPaid": false,
            "createdAt": "2023-08-10T05:09:14Z",
            "items": [
                ["productName": "Organic Banana", "quantity": 2, "price": 1.5, "imageUrl": "https://example.com/banana.jpg"],
                ["productName": "Red Apple", "quantity": 1, "price": 2.0, "imageUrl": "https://example.com/apple.jpg"]
            ],
            "street": "246/ A",
            "province": "Hồ Chí Minh",
            "district": "Quận 1",
            "ward": "Phường Bến Nghé"
        ])))
    }
}
