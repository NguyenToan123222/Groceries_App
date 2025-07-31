//
//  CategoriesView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/4/25.
//
import SwiftUI

struct CategoriesView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var explorVM = ExploreViewModel.shared
    @State private var animateCells = false

    var columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(explorVM.listArr.indices, id: \.self) { index in
                                let cObj = explorVM.listArr[index]
                                // Nếu index = 0, thì cObj = CategoryModel(id: 1, name: "Trái cây", image: "fruit.jpg", color: "53B175").
                                NavigationLink(destination: ExploreItemsView(itemsVM: ExploreItemViewModel(catObj: cObj))) {
                                    ExploreCategoryCell(cObj: cObj)
                                        .aspectRatio(0.95, contentMode: .fit)
                                        .offset(x: animateCells ? 0 : -50)
                                        .opacity(animateCells ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.05), value: animateCells)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("All Categories")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
            }
            .onAppear {
                animateCells = true
                explorVM.fetchCategories()
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
