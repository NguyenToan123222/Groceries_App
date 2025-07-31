//
//  SectionTitleAll.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 9/12/24.
//

import SwiftUI

struct SectionTitleAll: View {
    @State var title: String = "Title"
    @State var titleAll: String = "View All"
    var sectionType: SectionType
    
    enum SectionType {
        case bestSelling
        case exclusiveOffers
        case allProducts
        case custom
    }
    
    @State private var isActive = false

    var body: some View {
        HStack {
            Text(title)
                .font(.customfont(.semibold, fontSize: 20))
                .foregroundColor(.primaryText)

            Spacer()

            Button(action: {
                isActive = true
            }) {
                Text(titleAll)
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.primaryApp)
            }

            // Hidden NavigationLink để trigger điều hướng
            NavigationLink(destination: destinationView(), isActive: $isActive) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        switch sectionType {
        case .bestSelling:
            BestSellingListView()
        case .exclusiveOffers:
            ExclusiveOffersListView()
        case .allProducts:
            ProductListView()
        case .custom:
            CategoriesView() // Không cần điều hướng ở đây vì đã xử lý bên ngoài
                
        }
    }
}


#Preview {
    NavigationView {
        SectionTitleAll(sectionType: .bestSelling)
            .padding(20)
    }
}
