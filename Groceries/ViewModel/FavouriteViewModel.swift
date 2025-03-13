//
//  FavouriteViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 14/3/25.
//

import SwiftUI

class FavouriteViewModel: ObservableObject

{
    static var shared: FavouriteViewModel = FavouriteViewModel()
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var listArr: [ProductModel] = []

   
    init() {
        serviceCallDeetail()
    }
    
    
    
    //MARK: ServiceCall
    
    func serviceCallDeetail(){
        
        ServiceCall.post(parameter: [:], path: Globs.SV_FAVORITE_LIST) { responseObj in
            if let response = responseObj as? NSDictionary {
                if response.value(forKey: KKey.status) as? String ?? "" == "1" {
                    // Kiểm tra trạng thái từ server ("1" nghĩa là thành công).
                    self.listArr = (response.value(forKey: "nutrition_list") as? NSArray ?? []).map({ obj in
                        return ProductModel(dict: obj as? NSDictionary ?? [:])
                    })
                    
                    
                    
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
