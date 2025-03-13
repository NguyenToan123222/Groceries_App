//
//  HomeViewModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 7/12/24.
//

import SwiftUI

class HomeViewModel: ObservableObject // HomeViewModel chịu trách nhiệm xử lý dữ liệu và logic cho màn hình Home.

{
    static var shared: HomeViewModel = HomeViewModel()
    
    @Published var selectTab: Int = 0
    @Published var txtSearch: String = ""
    
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var offerArr: [ProductModel] = []
    @Published var bestArr: [ProductModel] = []
    @Published var listArr: [ProductModel] = []
    @Published var typeArr: [TypeModel] = []
    // @Published: Khi dữ liệu thay đổi, giao diện sẽ tự động cập nhật.
    

    
    init() {
        serviceCallList()
    }
    
    
    
    //MARK: ServiceCall
    
    func serviceCallList(){
        /*
         - ServiceCall.post(...): Gửi một yêu cầu API kiểu POST đến server.
         + parameter: [:]: Không có tham số nào được gửi lên server (gửi một dictionary rỗng).
         + path: Globs.SV_HOME: URL API được lấy từ Globs.SV_HOME, ví dụ: static let SV_HOME = BASE_URL + "home" // "http://localhost:3001/api/app/home"
         + isToken: true: Cho biết yêu cầu này cần gửi kèm token để xác thực.
         */
        ServiceCall.post(parameter: [:], path: Globs.SV_HOME) { responseObj in
            if let response = responseObj as? NSDictionary {
                /*
                - responseObj: Kết quả server trả về.
                -> Kiểm tra xem responseObj có phải kiểu NSDictionary không.
                 */
                if response.value(forKey: KKey.status) as? String ?? "" == "1" { // status so sánh == 1 thì success
                   // Kiểm tra trạng thái từ server ("1" nghĩa là thành công).
                    if let payloadObj = response.value(forKey: KKey.payLoad) as? NSDictionary {
                        /*
                         Kiểm tra xem "payload" có tồn tại không.
                ---------------------------------------
                         {
                           "status": "1",
                          ✅"payload": {
                                 "offer_list": [...],
                                 "best_sell_list": [...],
                                 "list": [...],
                                 "type_list": [...]
                           }
                         }
                         */
                        
                        self.offerArr = (payloadObj.value(forKey: "offer_list") as? NSArray ?? []).map({ obj in
                            return ProductModel(dict: obj as? NSDictionary ?? [:])
                        })
                        
                        self.bestArr = (payloadObj.value(forKey: "best_sell_list") as? NSArray ?? []).map({ obj in
                            
                            return ProductModel(dict: obj as? NSDictionary ?? [:])
                        })
                        
                        self.listArr = (payloadObj.value(forKey: "list") as? NSArray ?? []).map({ obj in
                            
                            return ProductModel(dict: obj as? NSDictionary ?? [:])
                        })
                        
                        self.typeArr = (payloadObj.value(forKey: "type_list") as? NSArray ?? []).map({ obj in
                            
                            return TypeModel(dict: obj as? NSDictionary ?? [:])
                        })
                        /*
                         → Lấy danh sách offer_list, bestArr, listArr, typeArr từ "payloadObj" và Ép kiểu thành NSArray, nếu không có thì dùng []
                         - Duyệt qua từng phần tử của danh sách
                         - Chuyển từng phần tử (NSDictionary) thành một ProductModel.
                         
                         --------------------------------------
                         
                         📌 Bước 1: Dữ liệu API trả về một JSON như sau :
                            {
                             "best_sell_list": [
                                 { "id": "1", "name": "Milk", "price": "3.99" },
                                 { "id": "2", "name": "Bread", "price": "2.49" }
                                ]
                             }

                         📌 Bước 2: Lấy danh sách từ JSON :
                           - Lấy best_sell_list từ JSON. Nếu không có dữ liệu, nó sẽ nhận [] (mảng rỗng).
                                -> let bestSellList = payloadObj.value(forKey: "best_sell_list") as? NSArray ?? []

                         [
       ❌bestSellList:       { "id": "1", "name": "Milk", "price": "3.99" },
                             { "id": "2", "name": "Bread", "price": "2.49" }
                         ]

                         📌 Bước 3: Chuyển đổi từng phần tử sang ProductModel
                             -> return ProductModel(dict: obj as? NSDictionary ?? [:])

                                    { "id": "1", "name": "Milk", "price": "3.99" }
                                 → ProductModel(dict: ["id": "1", "name": "Milk", "price": "3.99"])
                                    { "id": "2", "name": "Bread", "price": "2.49" }
                                 → ProductModel(dict: ["id": "2", "name": "Bread", "price": "2.49"])
                         
                         📌 Bước 4: Kết quả cuối cùng
                                 self.bestArr = [
                                     ProductModel(dict: ["id": "1", "name": "Milk", "price": "3.99"]),
                                     ProductModel(dict: ["id": "2", "name": "Bread", "price": "2.49"])
                                 ]
                        ----------------------------------------------
                                 [
                                     ProductModel(id: "1", name: "Milk", price: "3.99"),
                                     ProductModel(id: "2", name: "Bread", price: "2.49")
                                 ]

                         
                         */
                        
                    }
                    
                }else{
                    self.errorMessage = response.value(forKey: KKey.message) as? String ?? "Fail"
                    self.showError = true
                }
            }
            
        } failure: { error in
            self.errorMessage = error?.localizedDescription ?? "Fail"
            self.showError = true
        }
    }
    
    
}
