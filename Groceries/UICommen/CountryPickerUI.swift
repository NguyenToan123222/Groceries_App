//import SwiftUI
//import CountryPicker
//
//// UIViewControllerRepresentable giúp chuyển đổi một UIViewController từ UIKit để dùng trong SwiftUI.
//struct CountryPickerUI: UIViewControllerRepresentable {
//   
//    @Binding var country: Country? // maybe nil
//    
//    class Coordinator: NSObject, CountryPickerDelegate {
//        
//        var parent: CountryPickerUI
//        //Tham chiếu đến CountryPickerUI để cập nhật dữ liệu
//
//        init(_ parent: CountryPickerUI) {
//            self.parent = parent
//        }
//        //self.parent là biến parent trong class Coordinator.
//        //parent bên phải là tham số được truyền vào khi tạo Coordinator.
//
//        
//        // This delegate method will be called when a country is selected
//        func countryPicker(didSelect country: CountryPicker.Country) {
//            //country = Country(code: "VN", name: "Vietnam").
//            parent.country = country
//            // = country → Gán giá trị của quốc gia đã chọn cho parent.country.
//
//        }
//    }
//    
//    func makeUIViewController(context: Context) -> CountryPickerViewController {
//        //Hàm này trả về một đối tượng -> (là màn hình chọn quốc gia).
//
//        let countryPicker = CountryPickerViewController()
//        //Khởi tạo một màn hình chọn quốc gia
//        
//        // Set the default country by its ISO code (e.g., "IN" for India)
//        countryPicker.selectedCountry = "IN" // Set default country code here
//        
//        countryPicker.delegate = context.coordinator
//        // Gán Coordinator làm delegate để nhận sự kiện khi người dùng chọn quốc gia.
//
//        return countryPicker
//    }
//    
//    func updateUIViewController(_ uiViewController: CountryPickerViewController, context: Context) {
//        // No need to update anything in this case
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//}
