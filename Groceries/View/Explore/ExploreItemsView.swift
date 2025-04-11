//
//  ExploreItemsView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//

import SwiftUI

struct ExploreItemsView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var itemsVM: ExploreItemViewModel
    
    var columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                // Tiêu đề và nút quay lại
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    
                    Text(itemsVM.cObj.name)
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(minWidth: 0, maxHeight: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    Button {
                        // Nút bộ lọc (có thể thêm nếu cần)
                    } label: {
                        Image("filter_ic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                
                // Danh sách sản phẩm
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(itemsVM.listArr, id: \.id) { pObj in
                            NavigationLink(destination: ProductDetailView(productId: pObj.id)) {
                                ProductCell(pObj: pObj, didAddCart: {
                                    CartViewModel.shared.serviceCallAddToCart(prodId: pObj.id, qty: 1) { isDone, msg in
                                        itemsVM.errorMessage = msg
                                        itemsVM.showError = true
                                    }
                                })
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .padding(.bottom, .bottomInsets + 60)
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .alert(isPresented: $itemsVM.showError) {
            Alert(title: Text(Globs.AppName), message: Text(itemsVM.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ExploreItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: ExploreCategoryModel(dict: [
                "cat_id": 1,
                "cat_name": "Fresh Fruits & Vegetable",
                "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
                "color": "53B175"
            ])))
        }
    }
}
