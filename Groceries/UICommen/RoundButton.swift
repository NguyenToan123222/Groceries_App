

import SwiftUI

struct RoundButton: View {
    
    @State var tittle: String = "Tittle"
    var didTap: (()->())?
    //   ?  Khi didTap chưa được gán giá trị, nó sẽ có giá trị mặc định là nil.

    
    var body: some View {
        Button{
            
            didTap?()
            /*
             -> Nó giúp kiểm tra xem didTap có giá trị "nil" hay không trước khi thực hiện gọi closure.
             
             + Nếu didTap có giá trị, nó sẽ được gọi bình thường.
             + Nếu didTap là nil, nó sẽ không làm gì cả và tránh lỗi chương trình bị crash.
             */
        } label: {
            Text (tittle)
                .font(.customfont(.semibold, fontSize: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
        .background(Color.primaryApp)
        .cornerRadius(20)

        
            }
}

#Preview {
    RoundButton()
        .padding(20)
}

