//
//  ExploreItemsView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 15/3/25.
//


import SwiftUI

struct ExploreItemsView: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var itemsVM = ExploreItemViewModel(catObj: ExploreCategoryModel (dict: [:]))

    var columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        ZStack{
            VStack {
                HStack{
                    Button {
                        mode.wrappedValue.dismiss()
                    }  label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    Spacer()
                    
                    Text (itemsVM.cObj.name)
                        .font(.customfont(.bold, fontSize: 20))
                        .frame(minWidth: 0, maxHeight: .infinity, alignment: .center)
                    Spacer()
                    
                    Button {
                    }  label: {
                        Image("filter_ic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(itemsVM.listArr, id: \.id) { pObj in
                            ProductCell(pObj: pObj, didAddCart: {
                                CartViewModel.serviceCallAddToCart(prodId: pObj.prodId, qty: 1) { isDone, msg in
                                    self.itemsVM.errorMessage = msg
                                    self.itemsVM.showError = true
                                }

                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .padding(.bottom, .bottomInsets + 60)
                }

            }
            .padding(.top, .topInsets)
            .padding(.horizontal, 20)
            
            }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct ExploreItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: ExploreCategoryModel(dict: [
                "cat_id": 1,
                "cat_name": "Frash Fruits & Vegetable",
                "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
                "color": "53B175"
            ] ) ))
        }

    }
}




//import SwiftUI
//
//struct ExploreItemsView: View {
//    
//    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
//    @StateObject var itemsVM = ExploreItemViewModel(catObj: ExploreCategoryModel (dict: [:]))
//    
//    var columns = [
//        GridItem(.flexible(), spacing: 15),
//        GridItem(.flexible(), spacing: 15)
//    ]
//    
//    var body: some View {
//        ZStack{
//            VStack {
//                
//                HStack{
//                    
//                    EmptyView()
//                        .frame(width: 40, height: 40)
//                    
//                    Spacer()
//                    
//                    Text("Category")
//                        .font(.customfont(.bold, fontSize: 20))
//                        .frame(height: 46)
//                    Spacer()
//                    
//                    Button(action: {
//                        
//                    }, label: {
//                        Image("add_green")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                    })
//                    .frame(width: 40, height: 40)
//                    
//                }
//                .padding(.top, .topInsets)
//                .padding(.horizontal, 20)
//                
//                
//                
//                ScrollView {
//                    LazyVGrid(columns: columns,  spacing:15) {
//                         
////                        ForEach(itemsVM.listArr, id: \.id) {
////                            pObj in
////                            ProductCell( pObj: pObj, width: .infinity ) {
////                                CartViewModel.serviceCallAddToCart(prodId: pObj.prodId, qty: 1) { isDone, msg in
////                                    
////                                    self.itemsVM.errorMessage = msg
////                                    self.itemsVM.showError = true
////                                }
////                            }
////                            
////                        }
//                    }
//                    .padding(.vertical, 10)
//                    .padding(.bottom, .bottomInsets + 60)
//                }
//            }
//            .padding(.top, .topInsets)
//            .padding(.horizontal, 20)
//        }
////        .alert(isPresented: $itemsVM.showError, content: {
////            Alert(title: Text(Globs.AppName), message: Text(itemsVM.errorMessage), dismissButton: .default(Text("OK")) )
////        })
//        .navigationTitle("")
//        .navigationBarBackButtonHidden(true)
//        .navigationBarHidden(true)
//        .ignoresSafeArea()
//    }
//}
//
//struct ExploreItemsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: ExploreCategoryModel(dict: [
//                "cat_id": 1,
//                "cat_name": "Frash Fruits & Vegetable",
//                "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTUshuJ5pq_Qn3RhB2FKXWNap5MYGl-JZZng&s",
//                "color": "53B175"
//            ] ) ))
//        }
//        
//    }
//}
