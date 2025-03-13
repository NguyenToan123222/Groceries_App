//
//  ProductDetailViewModel.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 13/3/25.
//

import SwiftUI

class ProductDetailViewModel: ObservableObject

{
    
    @Published var pObj: ProductModel = ProductModel(dict: [:])
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var nutritionArr: [NutritionModel] = []
    @Published var bestArr: [ImageModel] = []
  
    @Published var isFav: Bool = false
    @Published var isShowDetail: Bool = false
    @Published var isShowNutrition: Bool = false
    @Published var qty: Int = 1
    
    
    func ShowDetail() {
        isShowDetail = !isShowDetail
    }
    func ShowNutrition() {
        isShowNutrition = !isShowNutrition
    }
    
    func addSubQTY(isAdd: Bool = true ) {
        if (isAdd) {
            qty += 1
            if(qty > 99) { qty = 99}
        }
        else {
            qty -= 1
            if(qty < 1) {
                qty = 1
            }
        }
    }
    init(prodObj: ProductModel) {
        self.pObj = prodObj
        serviceCallDeetail()
    }
    
    
    
    //MARK: ServiceCall
    
    func serviceCallDeetail(){
        
        ServiceCall.post(parameter: ["prod_id":self.pObj.prodId], path: Globs.SV_PRODUCT_DETAIL) { responseObj in
            if let response = responseObj as? NSDictionary {
                
                
                if response.value(forKey: KKey.status) as? String ?? "" == "1" {
                   // Kiểm tra trạng thái từ server ("1" nghĩa là thành công).
                    if let payloadObj = response.value(forKey: KKey.payLoad) as? NSDictionary {
                    
                        self.pObj = ProductModel(dict: payloadObj)
                        
                        self.nutritionArr = (payloadObj.value(forKey: "nutrition_list") as? NSArray ?? []).map({ obj in
                            return NutritionModel(dict: obj as? NSDictionary ?? [:])
                        })
                        
                        self.bestArr = (payloadObj.value(forKey: "image") as? NSArray ?? []).map({ obj in
                            
                            return ImageModel(dict: obj as? NSDictionary ?? [:])
                        })
                        
                        
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
    
    func serviceCallAddRemoveFav(){
            ServiceCall.post(parameter: ["prod_id": self.pObj.prodId ], path: Globs.SV_ADD_REMOVE_FAVORITE ) { responseObj in
                if let response = responseObj as? NSDictionary {
                    if response.value(forKey: KKey.status) as? String ?? "" == "1" {
                        
                        self.isFav = !self.isFav
                        HomeViewModel.shared.serviceCallList() // đồng bộ data trên Home
                        
                        self.errorMessage = response.value(forKey: KKey.message) as? String ?? "Done"
                        self.showError = true
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
