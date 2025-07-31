////
////  AddressViewModel.swift
////  Groceries
////
////  Created by Nguyễn Toàn on 12/4/25.
////
//
//import SwiftUI
//import Combine
//
//class AddressViewModel: ObservableObject {
//    static let shared = AddressViewModel()
//    
//    @Published var listAddresses: [AddressModel] = []
//    @Published var provinces: [ProvinceModel] = []
//    @Published var districts: [DistrictModel] = []
//    @Published var wards: [WardModel] = []
//    
//    @Published var showError = false
//    @Published var errorMessage = ""
//    @Published var showSuccess = false
//    @Published var successMessage = ""
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        // Khởi tạo nếu cần
//    }
//    
//    // MARK: - Lấy danh sách tỉnh/thành
//    func fetchProvinces() {
//        ServiceCall.get(path: Globs.SV_ADDRESS_LIST + "/provinces") { responseObj in
//            if let response = responseObj as? [[String: Any]] {
//                DispatchQueue.main.async {
//                    self.provinces = response.map { ProvinceModel(dict: $0 as NSDictionary) }
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to fetch provinces"
//                self.showError = true
//            }
//        }
//    }
//    
//    // MARK: - Lấy danh sách quận/huyện theo tỉnh
//    func fetchDistricts(provinceId: Int) {
//        ServiceCall.get(path: Globs.SV_ADDRESS_LIST + "/districts/\(provinceId)") { responseObj in
//            if let response = responseObj as? [[String: Any]] {
//                DispatchQueue.main.async {
//                    self.districts = response.map { DistrictModel(dict: $0 as NSDictionary) }
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to fetch districts"
//                self.showError = true
//            }
//        }
//    }
//    
//    // MARK: - Lấy danh sách phường/xã theo quận
//    func fetchWards(districtId: Int) {
//        ServiceCall.get(path: Globs.SV_ADDRESS_LIST + "/wards/\(districtId)") { responseObj in
//            if let response = responseObj as? [[String: Any]] {
//                DispatchQueue.main.async {
//                    self.wards = response.map { WardModel(dict: $0 as NSDictionary) }
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to fetch wards"
//                self.showError = true
//            }
//        }
//    }
//    
//    // MARK: - Lấy danh sách địa chỉ của người dùng
//    func fetchUserAddresses(userId: Int) {
//        ServiceCall.get(path: Globs.SV_ADDRESS_LIST + "/user/\(userId)") { responseObj in
//            if let response = responseObj as? [String: Any],
//               let content = response["content"] as? [[String: Any]] {
//                DispatchQueue.main.async {
//                    self.listAddresses = content.map { AddressModel(dict: $0 as NSDictionary) }
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to fetch addresses"
//                self.showError = true
//            }
//        }
//    }
//    
//    // MARK: - Thêm địa chỉ mới
//    func addAddress(address: AddressModel, completion: @escaping (Bool) -> Void) {
//        let parameters: [String: Any] = [
//            "userId": address.userId,
//            "provinceId": address.provinceId,
//            "districtId": address.districtId,
//            "wardId": address.wardId,
//            "street": address.street,
//            "isDefault": address.isDefault
//        ]
//        
//        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_ADDRESS_LIST + "/add") { responseObj in
//            if let response = responseObj as? [String: Any] {
//                DispatchQueue.main.async {
//                    self.successMessage = "Address added successfully"
//                    self.showSuccess = true
//                    self.fetchUserAddresses(userId: address.userId) // Cập nhật danh sách
//                    completion(true)
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to add address"
//                self.showError = true
//                completion(false)
//            }
//        }
//    }
//    
//    // MARK: - Cập nhật địa chỉ
//    func updateAddress(address: AddressModel, completion: @escaping (Bool) -> Void) {
//        let parameters: [String: Any] = [
//            "userId": address.userId,
//            "provinceId": address.provinceId,
//            "districtId": address.districtId,
//            "wardId": address.wardId,
//            "street": address.street,
//            "isDefault": address.isDefault
//        ]
//        
//        ServiceCall.put(parameter: parameters as NSDictionary, path: Globs.SV_ADDRESS_LIST + "/\(address.id)") { responseObj in
//            if let response = responseObj as? [String: Any] {
//                DispatchQueue.main.async {
//                    self.successMessage = "Address updated successfully"
//                    self.showSuccess = true
//                    self.fetchUserAddresses(userId: address.userId) // Cập nhật danh sách
//                    completion(true)
//                }
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to update address"
//                self.showError = true
//                completion(false)
//            }
//        }
//    }
//    
//    // MARK: - Xóa địa chỉ
//    func removeAddress(addressId: String, userId: Int) {
//        ServiceCall.delete(path: Globs.SV_ADDRESS_LIST + "/\(addressId)") { responseObj in
//            DispatchQueue.main.async {
//                self.successMessage = "Address removed successfully"
//                self.showSuccess = true
//                self.fetchUserAddresses(userId: userId) // Cập nhật danh sách
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to remove address"
//                self.showError = true
//            }
//        }
//    }
//    
//    // MARK: - Đặt địa chỉ mặc định
//    func setDefaultAddress(addressId: String, userId: Int) {
//        ServiceCall.put(parameter: [:], path: Globs.SV_ADDRESS_LIST + "/\(addressId)/set-default") { responseObj in
//            DispatchQueue.main.async {
//                self.successMessage = "Address set as default"
//                self.showSuccess = true
//                self.fetchUserAddresses(userId: userId) // Cập nhật danh sách
//            }
//        } failure: { error in
//            DispatchQueue.main.async {
//                self.errorMessage = error?.localizedDescription ?? "Failed to set default address"
//                self.showError = true
//            }
//        }
//    }
//}
