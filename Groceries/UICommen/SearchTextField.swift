//
//  SearchTextField.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 8/12/24.
//

import SwiftUI

struct SearchTextField: View {
    
    
    @State var placeholder: String = "Placeholder"
    @Binding var txt: String
    
    
    var body: some View {
        
        HStack (spacing: 15){
            Image ("search")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            
            TextField(placeholder, text: $txt)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(minWidth: 0, maxWidth: .infinity)
        }
        .frame(height: 30)
        .padding(15)
        .background(Color(hex: "F2F3F3"))
        .cornerRadius(16)
    }
}


struct SearchTextField_Previews: PreviewProvider {
    
    @State static var txt: String = ""
    static var previews: some View {
        SearchTextField(placeholder: "Search Store", txt: $txt)
            .padding(15)
    }
}

