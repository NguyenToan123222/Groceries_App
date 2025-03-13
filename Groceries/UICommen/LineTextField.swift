//
//  LineTextField.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 20/9/24.
//

import SwiftUI

struct LineTextField: View {
    @Binding var txt: String
    @State var title: String = "Title"
    @State var placeholder: String = "Placeholder"
    @State var keyboardType: UIKeyboardType = .default
    
    
    var body: some View {
        VStack {
            Text(title)
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.textTitle)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
          
                TextField(placeholder, text: $txt)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(height: 40)
            
            Divider()

        }
    }
}

struct LineTextField_Previews: PreviewProvider {
    static var previews: some View {
        @State var txt: String = ""
        LineTextField(txt: $txt)
    }
}


struct LineSecureField: View {
    
    @State var title: String = "Title"
    @State var placeholder: String = "Placeholder"
    
    @Binding var txt: String
    @Binding var isShowPassword: Bool
 
    
    
    var body: some View {
        VStack {
            Text(title)
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.textTitle)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            if (isShowPassword) {
                TextField(placeholder, text: $txt)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .modifier(ShowButton(isShow: $isShowPassword))
                    .frame(height: 40)

            }
            else {
                SecureField(placeholder, text: $txt)
                    .modifier(ShowButton(isShow: $isShowPassword))
                    .autocapitalization(.none)
                    .frame(height: 40)
            }
            Divider()

        }
    }
}


struct LineSecureField_Previews: PreviewProvider {
    static var previews: some View {
        @State var txt: String = ""
        @State var isShowPassword: Bool = false
        
        LineSecureField(txt: $txt, isShowPassword: $isShowPassword)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
