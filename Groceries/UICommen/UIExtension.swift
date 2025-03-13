

import SwiftUI

enum Gilroy: String {
    case regular = "Gilroy-Regular"
    case medium = "Gilroy-Medium"
    case semibold = "Gilroy-SemiBold"
    case bold = "Gilroy-Bold"
}

extension Font {
    
    static func customfont(_ font: Gilroy, fontSize: CGFloat) -> Font {
        custom(font.rawValue, size: fontSize)
    }
}

extension CGFloat {
    
    static var screenWidth: Double {
        return UIScreen.main.bounds.size.width
    }
    
    static var screenHeight: Double {
        return UIScreen.main.bounds.size.height
    }
    // caculated per of Width Screen
    static func widthPer(per: Double) -> Double {
        return screenWidth * per
    }
    
    static func heightPer(per: Double) -> Double {
        return screenHeight * per
    }
     /*
      "keyWindow" là cửa sổ chính đang hiển thị và nhận tương tác của người dùng.
      Nó chính là nơi chứa toàn bộ UI của ứng dụng trên màn hình.
      */
    //KC từ mép trên đến Safe Area
    static var topInsets: Double {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.top
        }
        return 0.0
    }
    
    static var bottomInsets: Double {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.bottom
        }
        return 0.0
    }
    
    static var horizontalInsets: Double {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.left + keyWindow.safeAreaInsets.right
        }
        return 0.0
    }
    
    static var verticalInsets: Double {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.top + keyWindow.safeAreaInsets.bottom
        }
        return 0.0
    }
    
}

extension Color {
    
    static var primaryApp: Color {
        return Color(hex: "53B175")
    }
    
    static var primaryText: Color {
        return Color(hex: "030303")
    }
    
    static var secondaryText: Color {
        return Color(hex: "828282")
    }
    
    static var textTitle: Color {
        return Color(hex: "7C7C7C")
    }
    
    static var placeholder: Color {
        return Color(hex: "B1B1B1")
    }
    
    static var darkGray: Color {
        return Color(hex: "4C4F4D")
    }

    // Đây là một initializer (hàm khởi tạo) giúp chuyển đổi chuỗi mã màu Hex thành một màu trong SwiftUI bằng cách phân tích và tách giá trị RGB hoặc ARGB.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        /*
         Loại bỏ các ký tự không phải số hoặc chữ (ví dụ: #, khoảng trắng, v.v.)
         Nếu hex = "#FF5733", sau khi xử lý sẽ thành "FF5733".
         */
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        /*
         int là một biến số nguyên không dấu 64-bit (UInt64), ban đầu có giá trị 0.
         Scanner(string: hex).scanHexInt64(&int) đọc chuỗi hex và chuyển thành số nguyên 64-bit.
         */
        // FF5733 -> 16729395 , assign int
        
        let a, r, g, b: UInt64
        //Khai báo 4 biến a, r, g, b để lưu giá trị Alpha (độ trong suốt), Đỏ (Red), Xanh lá (Green), Xanh dương (Blue).

        switch hex.count {
            /*
             3 ký tự: RGB 12-bit (#RGB)
             6 ký tự: RGB 24-bit (#RRGGBB)
             8 ký tự: ARGB 32-bit (#AARRGGBB)
             */
            case 3: // RGB(12 -bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            /*
             A mặc định = 255
             R = (int >> 8) * 17
             G = ((int >> 4) & 0xF) * 17
             B = (int & 0xF) * 17
            
             => hex = "F37" // => int = 0xF37

             F = 0xF = 15  -> R = 15 * 17 = 255
             3 = 0x3 =  3  -> G =  3 * 17 = 51
             7 = 0x7 =  7  -> B =  7 * 17 = 119
             A = 255
             → Màu tương ứng: (255, 51, 119, 255) (Đỏ tươi hơi hồng)
             */
            
            
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            /*
             A mặc định = 255
             R = int >> 16
             G = (int >> 8) & 0xFF
             B = int & 0xFF
             
             => hex = "FF3377" // => int = 0xFF3377

             R = (0xFF3377 >> 16)       = 0xFF = 255
             G = (0xFF3377 >> 8) & 0xFF = 0x33 = 51
             B =  0xFF3377 & 0xFF       = 0x77 = 119
             A = 255

             */
            
            
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            /*
             A = int >> 24
             R = (int >> 16) & 0xFF
             G = (int >> 8) & 0xFF
             B = int & 0xFF
             
             => hex = "80FF3377"  => int = 0x80FF3377

             A = (0x80FF3377 >> 24)      = 0x80 = 128
             R = (0x80FF3377 >> 16) & 0xFF = 0xFF = 255
             G = (0x80FF3377 >> 8)  & 0xFF = 0x33 = 51
             B =  0x80FF3377 & 0xFF       = 0x77 = 119

             */
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            // black
        }
        
        self.init(
            .sRGB,
            /*
             Mỗi giá trị màu (R, G, B, A) cần được chia cho 255 để chuyển về phạm vi 0.0 - 1.0 (chuẩn SwiftUI).
             Kênh Alpha (opacity) cũng được chia cho 255 để xác định độ trong suốt.
             
             R = 255 → 255 / 255 = 1.0
             G = 51  →  51 / 255 = 0.2
             B = 119 → 119 / 255 = 0.47
             A = 128 → 128 / 255 = 0.5

             Color(.sRGB, red: 1.0, green: 0.2, blue: 0.47, opacity: 0.5)
             */
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ShowButton: ViewModifier {
    @Binding var isShow: Bool
    
    public func body(content: Content) -> some View {
        // content: Content là một view mà ViewModifier áp dụng lên.

        HStack {
            content
            // content chính là view gốc được áp dụng ShowButton.
            Button {
                isShow.toggle()
            } label: {
                Image(systemName: isShow ? "eye.fill" : "eye.slash.fill" )
                    /*
                     Nếu isShow == false
                     ➝ Hiển thị "eye.fill" (hiện nội dung).
                     Nếu isShow == true
                     ➝ Hiển thị "eye.slash.fill" (ẩn nội dung).
                     */
                    .foregroundColor(.textTitle)
            }

        }
    }
}



extension View {
    //  corner :Chỉ định góc nào cần bo tròn.
    func cornerRadius(_ radius: CGFloat, corner:  UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corers: corner))
        // để bo tròn một số góc thay vì tất cả:
        // .cornerRadius(20, corner: [.topLeft, .bottomRight])

    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corers: UIRectCorner = .allCorners
    /*
     RoundedCorner: Một hình (Shape) tùy chỉnh.
     radius: Độ cong góc (mặc định vô cực để bo tròn tối đa).
     corers: Xác định góc nào cần bo tròn (mặc định tất cả góc).
     */
    
    func path(in rect: CGRect) -> Path {
        /*
         Đây là một hàm bắt buộc trong SwiftUI khi tạo Shape.
         Nhận vào rect (một hình chữ nhật CGRect), nơi cần vẽ Path.
         Trả về một Path (đường viền bo góc của hình chữ nhật).
         */
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corers, cornerRadii: CGSize(width: radius, height: radius))
        /*
         UIBezierPath: Một công cụ giúp vẽ hình dạng phức tạp trong UIKit.
         roundedRect: rect: Xác định hình chữ nhật cần bo góc.
         byRoundingCorners: corers: Chỉ định góc nào sẽ được bo tròn (truyền vào từ biến corers).
         cornerRadii: CGSize(width: radius, height: radius): Xác định độ cong của góc (truyền từ biến radius).
         */
        return Path(path.cgPath)
       // Chuyển UIBezierPath thành CGPath
    }
}
