//
//  DeliveryAddressViewModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 17/3/25.

import SwiftUI
import Combine

// Response struct to match AddressResponse DTO from backend
struct AddressResponse: Codable { // cho phép struct tự động mã hóa (encode) thành JSON và giải mã (decode) từ JSON, phù hợp để làm việc với API.
    let id: String?
    let street: String
    let provinceId: Int
    let districtId: Int
    let wardId: Int
    let userId: Int
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, street, provinceId, districtId, wardId, userId, isDefault
        // Định nghĩa các khóa để encode/decode JSON.
        // Xác định khóa JSON cho từng thuộc tính.
        /*
         case s2_id = "id"
         case s2_street = "street"
         case s2_provinceId = "provinceId"
         case s2_districtId = "districtId"
         case s2_wardId = "wardId"
         case s2_userId = "userId"
         case s2_isDefault = "isDefault"
         */
    }
    
    init(from decoder: Decoder) throws {// Tùy chỉnh cách Address2 đọc dữ liệu từ JSON để gán vào các thuộc tính
        let container = try decoder.container(keyedBy: CodingKeys.self) // Tạo container từ decoder để truy cập các khóa JSON
        if let uuid = try? container.decode(UUID.self, forKey: .id) { // Thử decode khóa "id" trong JSON thành kiểu UUID. Nếu decode thành công, gán vào biến uuid. (try?: Trả về nil nếu decode thất bại (không ném lỗi).)
            id = uuid.uuidString // Lưu "id" dưới dạng chuỗi nếu JSON cung cấp UUID.
        } else { // Xử lý trường hợp "id" là chuỗi (String) hoặc không tồn tại.
            id = try container.decodeIfPresent(String.self, forKey: .id)
            /*
             Decode khóa "id" thành String, dùng decodeIfPresent để trả về nil nếu "id" không có trong JSON.
             - Cú pháp:
             decodeIfPresent: Không ném lỗi nếu khóa thiếu, phù hợp với s2_id: String?.
             try: Ném lỗi nếu "id" tồn tại nhưng không phải chuỗi.
             - Tại sao?:
             Backend có thể trả "id" là chuỗi (như "abc123") hoặc không có "id".
             s2_id là String?, hỗ trợ cả nil.
             - Ý nghĩa:
             Gán s2_id từ JSON nếu là chuỗi, hoặc nil nếu không có.
             */
        }
        // try: Ném lỗi nếu "street" thiếu hoặc không phải chuỗi.
        street = try container.decode(String.self, forKey: .street) // Decode khóa "street" thành String, gán vào s2_street.
        provinceId = try container.decode(Int.self, forKey: .provinceId) // Decode "provinceId" thành Int, gán vào s2_provinceId.
        districtId = try container.decode(Int.self, forKey: .districtId) // Decode "districtId" thành Int.
        wardId = try container.decode(Int.self, forKey: .wardId)
        userId = try container.decode(Int.self, forKey: .userId)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
    }
    
    func toAddressModel() -> AddressModel {// Chuyển đổi dữ liệu từ DTO sang model nội bộ.
        AddressModel(
            id: id ?? UUID().uuidString, // s1_id: s2_id ?? UUID().uuidString,
            userId: userId,
            street: street,
            provinceId: provinceId,
            districtId: districtId,
            wardId: wardId,
            isDefault: isDefault
        )
    }
}

// Response struct for paginated address list
struct AddressListResponse: Codable {
    let content: [AddressResponse]
}

class DeliveryAddressViewModel: ObservableObject {
    static var shared = DeliveryAddressViewModel() // Singleton đảm bảo trạng thái (như danh sách tỉnh, địa chỉ) nhất quán.
    
    @Published var street: String = ""
    @Published var selectedProvince: ProvinceModel?
    @Published var selectedDistrict: DistrictModel?
    @Published var selectedWard: WardModel?
    @Published var isDefault: Bool = false
    
    @Published var provinces: [ProvinceModel] = [] // provinces = [ProvinceModel(id: 1, name: "Hà Nội"), ProvinceModel(id: 2, name: "TP.HCM")]
    @Published var districts: [DistrictModel] = []
    @Published var wards: [WardModel] = []
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    @Published var listArr: [AddressModel] = [] // danh sách địa chỉ của người dùng
    // Dictionary để lưu trữ tên của Province, District, và Ward
    @Published var provinceNames: [Int: String] = [:]
    @Published var districtNames: [Int: String] = [:]
    @Published var wardNames: [Int: String] = [:]
    /*
     provinceNames = [1: "Hà Nội", 2: "TP.HCM"].
     districtNames = [101: "Ba Đình", 102: "Hoàn Kiếm", 201: "Quận 1"].
     wardNames = [1001: "Cửa Nam", 1003: "Hàng Bạc", 2001: "Bến Nghé"].
     */
    // để hiển thị tên địa điểm trong danh sách địa chỉ
    
    private var cancellables = Set<AnyCancellable>() // lưu các subscription của Combine. Đảm bảo hủy subscription khi không cần, tránh rò rỉ bộ nhớ
    
    init() {} // Hàm khởi tạo rỗng, không làm gì vì các thuộc tính đã có giá trị mặc định ("", [], nil, false).
    // Singleton shared được dùng để chia sẻ trạng thái (như danh sách tỉnh, địa chỉ) giữa các view. Hàm init() {} đảm bảo instance này được tạo đúng cách.
    
    // Clear all input fields
    func clearAll() { // Dùng sau khi thêm/sửa địa chỉ để làm mới form.
        street = ""
        selectedProvince = nil
        selectedDistrict = nil
        selectedWard = nil
        isDefault = false
        districts = []
        wards = []
    }
    
    // Set data for editing
    func setData(aObj: AddressModel) { // Điền sẵn dữ liệu địa chỉ vào form khi chỉnh sửa
        street = aObj.street
        isDefault = aObj.isDefault
    }
    
    // MARK: Fetch Location Data
    
    func fetchProvinces() {
        guard let url = URL(string: Globs.SV_GET_PROVINCES) else {
            errorMessage = "Invalid provinces URL"
            showError = true
            return
        }
        
        print("Fetching provinces from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url) // Bắt đầu gọi API để lấy dữ liệu tỉnh
            .map { (data, response) in
                print("Provinces Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                return data
            }
            .decode(type: [ProvinceModel].self, decoder: JSONDecoder()) // chuyển "data" thành [ProvinceModel] (mảng các ProvinceModel). JSONDecoder(): Bộ giải mã JSON tiêu chuẩn
            .receive(on: DispatchQueue.main) // đảm bảo các bước tiếp theo (như cập nhật UI) chạy trên main queue.
            .sink { completion in // nhận kết quả từ publisher.
                if case .failure(let error) = completion {
                    print("Failed to fetch provinces: \(error)")
                    self.errorMessage = "Failed to fetch provinces: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { provinces in // Bắt đầu xử lý danh sách tỉnh (dữ liệu khi API thành công)
                print("Fetched \(provinces.count) provinces")
                self.provinces = provinces
                // Lưu tên provinces vào dictionary
                provinces.forEach { province in
                    self.provinceNames[province.id] = province.name
                    //Lưu tên tỉnh vào provinceNames ([Int: String]) với key là province.id và value là province.name.
                }
            }
            .store(in: &cancellables) // Quản lý vòng đời API cal
    }
    
    func fetchDistricts(provinceId: Int) {
        guard let url = URL(string: "\(Globs.SV_GET_DISTRICTS)/\(provinceId)") else {
            errorMessage = "Invalid districts URL"
            showError = true
            return
        }
        
        print("Fetching districts for provinceId \(provinceId) from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) in
                print("Districts Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                return data
            }
            .decode(type: [DistrictModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch districts: \(error)")
                    self.errorMessage = "Failed to fetch districts: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { districts in
                print("Fetched \(districts.count) districts")
                self.districts = districts
                // Lưu tên districts vào dictionary
                districts.forEach { district in
                    self.districtNames[district.id] = district.name
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchWards(districtId: Int) {
        guard let url = URL(string: "\(Globs.SV_GET_WARDS)/\(districtId)") else {
            errorMessage = "Invalid wards URL"
            showError = true
            return
        }
        
        print("Fetching wards for districtId \(districtId) from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) in
                print("Wards Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                return data
            }
            .decode(type: [WardModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch wards: \(error)")
                    self.errorMessage = "Failed to fetch wards: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { wards in
                print("Fetched \(wards.count) wards")
                self.wards = wards
                // Lưu tên wards vào dictionary
                wards.forEach { ward in
                    self.wardNames[ward.id] = ward.name
                }
            }
            .store(in: &cancellables)
    }
    
    // Fetch tất cả dữ liệu địa điểm cần thiết cho danh sách địa chỉ của User ID
    func fetchAllLocationNames(userId: Int) {
        // Bước 1: Lấy tất cả provinces
        fetchProvinces()
        
        // Bước 2: Sau khi lấy provinces, lấy districts và wards cho từng địa chỉ
        $listArr
            .sink { addresses in
                // Duyệt qua từng địa chỉ để lấy provinceId, districtId duy nhất
                let uniqueProvinceIds = Set(addresses.map { $0.provinceId })
                /*
                 addresses.map { $0.provinceId }: Lấy provinceId từ mỗi AddressModel trong addresses, tạo mảng [Int].
                 Set(...): Chuyển mảng thành Set để loại bỏ trùng lặp, chỉ giữ các provinceId duy nhất.
                 */
                let uniqueDistrictIds = Set(addresses.map { $0.districtId })
                
                // Lấy districts cho từng provinceId (uniqueDistrictIds = [101, 201])
                uniqueProvinceIds.forEach { provinceId in
                    self.fetchDistricts(provinceId: provinceId)
                }
                
                // Lấy wards cho từng districtId
                uniqueDistrictIds.forEach { districtId in
                    self.fetchWards(districtId: districtId)
                }
            }
            .store(in: &cancellables) // Ngăn subscription bị hủy sớm, đảm bảo pipeline Combine hoạt động.
    }
    
    // Bỏ hàm fetchLocationNames vì không cần gọi API riêng lẻ nữa
    /*
    func fetchLocationNames(for address: AddressModel) {
        // Fetch Province name
        if provinceNames[address.provinceId] == nil {
            guard let url = URL(string: "\(Globs.SV_GET_PROVINCES)/\(address.provinceId)") else { return }
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: ProvinceModel.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch province name: \(error)")
                    }
                } receiveValue: { province in
                    self.provinceNames[province.id] = province.name
                }
                .store(in: &cancellables)
        }
        
        // Fetch District name
        if districtNames[address.districtId] == nil {
            guard let url = URL(string: "\(Globs.SV_GET_DISTRICTS)/\(address.provinceId)") else { return }
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: [DistrictModel].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch district name: \(error)")
                    }
                } receiveValue: { districts in
                    if let district = districts.first(where: { $0.id == address.districtId }) {
                        self.districtNames[district.id] = district.name
                    }
                }
                .store(in: &cancellables)
        }
        
        // Fetch Ward name
        if wardNames[address.wardId] == nil {
            guard let url = URL(string: "\(Globs.SV_GET_WARDS)/\(address.districtId)") else { return }
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: [WardModel].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch ward name: \(error)")
                    }
                } receiveValue: { wards in
                    if let ward = wards.first(where: { $0.id == address.wardId }) {
                        self.wardNames[ward.id] = ward.name
                    }
                }
                .store(in: &cancellables)
        }
    }
    */
    
    // MARK: Service Calls
    
    func serviceCallList(userId: Int) {
        guard let url = URL(string: "\(Globs.SV_ADDRESS_LIST)/user/\(userId)") else {
            errorMessage = "Invalid address list URL"
            showError = true
            return
        }
        
        print("Fetching address list for userId \(userId) from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data } // Lấy data từ tuple (data, response).
            .decode(type: AddressListResponse.self, decoder: JSONDecoder()) // Chuyển JSON thành model Swift.
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch addresses: \(error)")
                    self.errorMessage = "Failed to fetch addresses: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { response in
                self.listArr = response.content.map { $0.toAddressModel() }
                print("Fetched \(self.listArr.count) addresses")
                // Fetch tên của Province, District, và Ward
                self.fetchAllLocationNames(userId: userId)  // lấy tên tỉnh, quận, phường cho listArr.
            }
            .store(in: &cancellables) // Lưu subscription vào cancellables để duy trì pipeline Combine. Ngăn subscription bị hủy sớm.
    }
    
    func serviceCallRemove(addressId: String, userId: Int) {
        guard let url = URL(string: "\(Globs.SV_ADDRESS_LIST)/\(addressId)") else {
            errorMessage = "Invalid remove address URL"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("Removing address with addressId \(addressId) from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to remove address: \(error)")
                    self.errorMessage = "Failed to remove address: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { _ in
                self.successMessage = "Address removed successfully"
                self.showSuccess = true
                self.serviceCallList(userId: userId)
            }
            .store(in: &cancellables)
    }
    
    func serviceCallUpdateAddress(aObj: AddressModel, userId: Int, didDone: (() -> Void)?) { // để thực hiện hành động sau khi cập nhật thành công
        //Đảm bảo tỉnh, quận, phường đã được chọn (không nil).
        guard let provinceId = selectedProvince?.id,
              let districtId = selectedDistrict?.id,
              let wardId = selectedWard?.id,
              let url = URL(string: "\(Globs.SV_ADDRESS_LIST)/\(aObj.id)")
        else {
            errorMessage = "Please select province, district, and ward"
            showError = true
            return
             }
        
        let parameters: [String: Any] = [
            "userId": userId,
            "street": street,
            "provinceId": provinceId,
            "districtId": districtId,
            "wardId": wardId,
            "isDefault": isDefault
        ]
        //parameters = ["userId": 500, "street": "456 Đường Láng", "provinceId": 1, "districtId": 101, "wardId": 1001, "isDefault": true].
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Thêm header Content-Type: application/json để báo API rằng body request là JSON. Đảm bảo API xử lý đúng định dạng dữ liệu.
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        /*
         Chuyển dictionary parameters thành Data (JSON) bằng JSONSerialization.
         try? bỏ qua lỗi nếu chuyển đổi thất bại (trả về nil).
         Ý nghĩa: Gửi dữ liệu địa chỉ trong body request
         */
        
        print("Updating address with addressId \(aObj.id) from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AddressResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to update address: \(error)")
                    self.errorMessage = "Failed to update address: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { _ in
                self.successMessage = "Address updated successfully"
                self.showSuccess = true
                self.clearAll() // Đảm bảo form không giữ dữ liệu cũ, tránh nhầm lẫn.
                self.serviceCallList(userId: userId) // cập nhật lại view
                didDone?() // hành động sau đó ( vd: đóng form...)
            }
            .store(in: &cancellables)
    }
    
    func serviceCallAddAddress(userId: Int, didDone: (() -> Void)?) {
        guard let provinceId = selectedProvince?.id,
              let districtId = selectedDistrict?.id,
              let wardId = selectedWard?.id,
              let url = URL(string: Globs.SV_ADD_ADDRESS) else {
            errorMessage = "Please select province, district, and ward"
            showError = true
            return
        }
        
        let parameters: [String: Any] = [
            "userId": userId,
            "street": street,
            "provinceId": provinceId,
            "districtId": districtId,
            "wardId": wardId,
            "isDefault": isDefault
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        print("Adding address from: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AddressResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to add address: \(error)")
                    self.errorMessage = "Failed to add address: \(error.localizedDescription)"
                    self.showError = true
                }
            } receiveValue: { _ in
                self.successMessage = "Address added successfully"
                self.showSuccess = true
                self.clearAll()
                self.serviceCallList(userId: userId)
                didDone?()
            }
            .store(in: &cancellables)
    }
}
