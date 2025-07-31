//
//  WriteReview.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 22/3/25.

import SwiftUI


struct WriteReviewView: View {
    @Binding var rating: Float
    @Binding var comment: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Write a Review")
                .font(.customfont(.bold, fontSize: 20))
                .foregroundColor(.primaryText)

            Text("Rating")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(index <= Int(rating) ? .orange : .gray)
                        .onTapGesture { // khi tap mới hiển thị sao
                            withAnimation {
                                rating = Float(index)
                            }
                      }
                }
                // rating = Float(index) cập nhật giá trị rating thành 3.0 (nếu chạm vào ngôi sao thứ 3), khiến các ngôi sao từ 1 đến 3 chuyển thành màu cam, còn ngôi sao 4 và 5 giữ màu xám.
            }

            Text("Comment (Optional)")
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $comment)
                .frame(height: 100)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )

            HStack(spacing: 20) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }

                Button(action: onSubmit) {
                    Text("Submit")
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(rating > 0 ? Color.green : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(rating == 0)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}
#Preview {
    WriteReviewView(
        rating: .constant(3.5),
        comment: .constant("Hihi"),
        onSubmit: {},
        onCancel: {}
    )
}

/*
 Ban đầu: Trạng thái khi rating = 0.0
 Vòng lặp ForEach chạy 5 lần, tạo 5 ngôi sao:
 
 Lần 1 (index = 1):
 Tạo ngôi sao: Kích thước 30x30, biểu tượng star.fill.
 Màu sắc: 1 <= Int(0.0) = 0 → False → Màu xám.
 Hành động khi chạm: rating = 1.0.
 Giao diện hiện tại: [★ (xám)]
 
 Lần 2 (index = 2):
 Tạo ngôi sao: Tương tự.
 Màu sắc: 2 <= 0 → False → Xám.
 Hành động: rating = 2.0.
 Giao diện hiện tại: [★ (xám) ★ (xám)]
 
 Lần 3 (index = 3): [★ (xám) ★ (xám) ★ (xám)]
 Lần 4 (index = 4): [★ (xám) ★ (xám) ★ (xám) ★ (xám)]
 Lần 5 (index = 5): [★ (xám) ★ (xám) ★ (xám) ★ (xám) ★ (xám)]
 
 Kết quả cuối cùng: 5 ngôi sao màu xám, vì không có sao nào được chọn (rating = 0.0).
 Người dùng chạm vào ngôi sao thứ 3 (index = 3)
 
 Khi chạm vào ngôi sao thứ 3:
 .onTapGesture kích hoạt.
 withAnimation { rating = Float(3) } chạy, đặt rating = 3.0.
 SwiftUI render lại giao diện với hiệu ứng hoạt hình.
 
 Vòng lặp ForEach chạy lại để cập nhật màu sắc:
 
 Lần 1 (index = 1):
 Màu sắc: 1 <= Int(3.0) = 3 → True → Màu cam.
 Giao diện: [★ (cam)]
 
 Lần 2 (index = 2):
 Màu sắc: 2 <= 3 → True → Cam.
 Giao diện: [★ (cam) ★ (cam)]
 
 Lần 3 (index = 3):
 Màu sắc: 3 <= 3 → True → Cam.
 Giao diện: [★ (cam) ★ (cam) ★ (cam)]
 
 Lần 4 (index = 4):
 Màu sắc: 4 <= 3 → False → Xám.
 Giao diện: [★ (cam) ★ (cam) ★ (cam) ★ (xám)]
 
 Lần 5 (index = 5):
 Màu sắc: 5 <= 3 → False → Xám.
 Giao diện: [★ (cam) ★ (cam) ★ (cam) ★ (xám) ★ (xám)]
 
 Kết quả: 3 ngôi sao đầu màu cam, 2 ngôi sao sau màu xám, với sự thay đổi màu diễn ra mượt mà.
 Người dùng chạm vào ngôi sao khác, ví dụ ngôi sao thứ 1 (index = 1)
 rating cập nhật thành 1.0.
 
 Vòng lặp chạy lại:
 Lần 1: 1 <= 1 → Cam → [★ (cam)]
 Lần 2: 2 <= 1 → Xám → [★ (cam) ★ (xám)]
 Lần 3: 3 <= 1 → Xám → [★ (cam) ★ (xám) ★ (xám)]
 Lần 4: 4 <= 1 → Xám → [★ (cam) ★ (xám) ★ (xám) ★ (xám)]
 Lần 5: 5 <= 1 → Xám → [★ (cam) ★ (xám) ★ (xám) ★ (xám) ★ (xám)]
 Kết quả: Chỉ ngôi sao đầu là cam, các ngôi sao còn lại là xám.
 */
