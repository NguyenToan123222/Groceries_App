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
    var didTap: (()->())?
    var body: some View {
        HStack {
            Text(title)
                .font(.customfont(.semibold, fontSize: 20))
                .foregroundColor(.primaryText)
            
            Spacer ()
            
            Text (titleAll)
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryApp)
        }
    }
}

#Preview {
    SectionTitleAll()
        .padding(20)
        
}
