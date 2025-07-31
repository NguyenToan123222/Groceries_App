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
                .foregroundColor(.black)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            TextField(placeholder, text: $txt)
                .keyboardType(keyboardType)
                .textContentType(.none) // Tắt gợi ý và tìm kiếm emoji
                .autocapitalization(.none) // Tắt tự động viết hoa đầu câu
                .disableAutocorrection(true) // Tắt tự động sửa lỗi
                .textInputAutocapitalization(.never) // Tắt tự động viết hoa
                .autocorrectionDisabled(true) // Tắt tự động sửa lỗi (iOS 15+)
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
                .foregroundColor(.black)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            if isShowPassword {
                TextField(placeholder, text: $txt)
                    .textContentType(.none) // Tắt gợi ý và tìm kiếm emoji
                    .autocapitalization(.none) // Tắt tự động viết hoa đầu câu
                    .disableAutocorrection(true) // Tắt tự động sửa lỗi
                    .textInputAutocapitalization(.never) // Tắt tự động viết hoa
                    .autocorrectionDisabled(true) // Tắt tự động sửa lỗi (iOS 15+)
                    .modifier(ShowButton(isShow: $isShowPassword))
                    .frame(height: 40)
            } else {
                SecureField(placeholder, text: $txt)
                    .textContentType(.none) // Tắt gợi ý và tìm kiếm emoji
                    .autocapitalization(.none) // Tắt tự động viết hoa đầu câu
                    .disableAutocorrection(true) // Tắt tự động sửa lỗi
                    .textInputAutocapitalization(.never) // Tắt tự động viết hoa
                    .autocorrectionDisabled(true) // Tắt tự động sửa lỗi (iOS 15+)
                    .modifier(ShowButton(isShow: $isShowPassword))
                    .frame(height: 40)
            }
            
            Divider()
        }
    }
}
struct LineSecureField_Previews: PreviewProvider {
    static var previews: some View {
        @State var txt: String = ""
        @State var isShowPassword: Bool = true
        
        LineSecureField(txt: $txt, isShowPassword: $isShowPassword)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
