//
//  UIKitExtension.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 23/9/24.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emaillRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        /*
         -> Kiểm tra chuỗi có đúng định dạng email không.
         Ví dụ hợp lệ: "test@example.com", "user.name123@domain.co.uk"
         Ví dụ không hợp lệ: "test@com", "@example.com"
         */
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emaillRegEx)
        /*
         -> Dùng NSPredicate (Regex) để kiểm tra xem có đúng định dạng "email(emaillRegEx)" hay không

         sử dụng Regex để định nghĩa quy tắc cho các chuỗi hợp lệ.
         */
        return emailTest.evaluate(with: self)
        /*
         -> evaluate(with: self) kiểm tra xem self (chuỗi gọi isValidEmail) có khớp với emaillRegEx không.
         
         Nếu đúng → Trả về true (Email hợp lệ).
         Nếu sai → Trả về false (Email không hợp lệ)
         */
    }
    
    func stringDateToDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        /*
         Đây là tham số mặc định, tức là nếu không truyền giá trị cho format, nó sẽ mặc định dùng "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         Hàm trả về một đối tượng Date?, có thể là nil nếu chuỗi không hợp lệ.

         */

        let dataFormat1 = DateFormatter() // dùng để chuyển đổi giữa chuỗi (String) và ngày tháng (Date).
        
        dataFormat1.dateFormat = format
        // dataFormat1: chuỗi sẽ được định dạng lại với cấu trúc định dạng ngày tháng
        // dateFormat : dateFormatter.dateFormat = "yyyy-MM-dd" -> theo " format "

        return dataFormat1.date(from: self)
        /*
        ->  date(from:) sẽ cố gắng chuyển đổi chuỗi ngày (String) thành một đối tượng Date.
         + Nếu chuyển đổi thành công, nó sẽ trả về một Date.
         + Nếu chuỗi không khớp với format, nó sẽ trả về nil.
         */
    }
    
    func stringDateChangeFormat(format: String, newFormat: String) -> String{
        let dataFormat1 = DateFormatter()
        dataFormat1.dateFormat = format
        // dataFormat1: chuỗi sẽ được định dạng lại với cấu trúc định dạng ngày tháng
        // dateFormat : dateFormatter.dateFormat = "yyyy-MM-dd" -> theo " format "
        
        if let dt = dataFormat1.date(from: self){
            /*
             -> Cố gắng chuyển đổi self (chuỗi gốc) thành Date theo định dạng đã chỉ định. -> theo " format "
             + Nếu chuyển đổi thành công, gán giá trị vào biến dt.
             + Nếu không chuyển đổi được (nil), sẽ vào phần else.
             */
            
            dataFormat1.dateFormat = newFormat
            // Thay đổi dateFormat sang định dạng mới (newFormat).
            
            return dataFormat1.string(from: dt)
            // chuyển đổi sang định dạng mới với "dt"
        }
        else {
            return ""
        }
    }
    
}

extension Date {
    func displayDate(format: String, addMinTime: Int = 0) -> String {
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = format
        
        let date = self.addingTimeInterval(TimeInterval(60 * addMinTime))
        /*
        - TimeInterval là kiểu số thực (Double), được dùng để biểu diễn khoảng thời gian tính bằng giây.
        - addingTimeInterval(_:) là phương thức của Date, giúp thêm hoặc bớt một khoảng thời gian.
         Nếu giá trị truyền vào dương, ngày giờ sẽ tăng.
         Nếu giá trị truyền vào âm, ngày giờ sẽ giảm.
         */
        return dataFormat.string(from: date)
    }
}
