//
//  AddDeliveryAddressView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 17/3/25.

import SwiftUI
import Combine

struct AddDeliveryAddressView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var deliveryVM = DeliveryAddressViewModel.shared
    // Giữ deliveryVM trong suốt vòng đời view, theo dõi thay đổi (như @Published properties).
    @EnvironmentObject var mainVM: MainViewModel
    // Cung cấp thông tin người dùng (như userObj.id) để kiểm tra đăng nhập.
    @State private var street = ""
    @State private var isProvinceLoaded = false
    @State private var isDistrictLoaded = false
    @State private var isWardLoaded = false
    var isEdit: Bool
    var editAddress: AddressModel?
    
    init(isEdit: Bool = false, editAddress: AddressModel? = nil) {
        self.isEdit = isEdit
        self.editAddress = editAddress
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Header
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(isEdit ? "Edit Address" : "Add Address")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                } // HStack
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
                .background(Color.white)
                .shadow(radius: 2)
                
                // Form
                Form {
                    Section(header: Text("Address Details")) {
                        TextField("House number, street name", text: $street)
                        
                        Picker("Province/City", selection: $deliveryVM.selectedProvince) {
                            if deliveryVM.provinces.isEmpty {// empty
                                Text("Loading provinces...").tag(nil as ProvinceModel?)
                            } else { // have date
                                Text("Select Province/City").tag(nil as ProvinceModel?)
                                ForEach(deliveryVM.provinces) { province in
                                    Text(province.name).tag(province as ProvinceModel?) // selectedProvince = province
                                }
                            }
                        }// Picker
                        // Xử lý hành động khi người dùng chọn tỉnh mới
                        // newValue: Giá trị mới của selectedProvince
                        .onChange(of: deliveryVM.selectedProvince) { newValue in
                            deliveryVM.selectedDistrict = nil // Xóa quận đã chọn vì tỉnh mới có thể có danh sách quận khác
                            deliveryVM.selectedWard = nil
                            deliveryVM.districts = []
                            deliveryVM.wards = []
                            isDistrictLoaded = false
                            isWardLoaded = false
                            //newValue?.id: Truy cập thuộc tính id của newValue (nếu newValue không phải nil)
                            //?. là optional chaining, chỉ lấy id nếu newValue có giá trị.
                            if let provinceId = newValue?.id {
                                deliveryVM.fetchDistricts(provinceId: provinceId)
                            }
                        }
                        
                        Picker("District", selection: $deliveryVM.selectedDistrict) {
                            if deliveryVM.districts.isEmpty {
                                Text(deliveryVM.selectedProvince == nil ? "Select a province first" : "Loading districts...").tag(nil as DistrictModel?)
                            } else {
                                Text("Select District").tag(nil as DistrictModel?)
                                ForEach(deliveryVM.districts) { district in
                                    Text(district.name).tag(district as DistrictModel?)
                                }
                            }
                        }
                        .disabled(deliveryVM.districts.isEmpty && deliveryVM.selectedProvince != nil)
                        //Picker bị vô hiệu hóa khi đã chọn "tỉnh" nhưng chưa tải được "quận"
                        .onChange(of: deliveryVM.selectedDistrict) { newValue in
                            deliveryVM.selectedWard = nil
                            deliveryVM.wards = []
                            isWardLoaded = false
                            if let districtId = newValue?.id {
                                deliveryVM.fetchWards(districtId: districtId)
                            }
                        }
                        
                        Picker("Ward", selection: $deliveryVM.selectedWard) {
                            if deliveryVM.wards.isEmpty {
                                Text(deliveryVM.selectedDistrict == nil ? "Select a district first" : "Loading wards...").tag(nil as WardModel?)
                            } else {
                                Text("Select Ward").tag(nil as WardModel?)
                                ForEach(deliveryVM.wards) { ward in
                                    Text(ward.name).tag(ward as WardModel?)
                                }
                            }
                        }
                        .disabled(deliveryVM.wards.isEmpty && deliveryVM.selectedDistrict != nil)
                        // Picker bị vô hiệu hóa khi đã chọn "quận" nhưng chưa tải được "phường"
                        
                        
                        Toggle("Set as default", isOn: $deliveryVM.isDefault)
                        
                    }
                }
                
                Spacer()
                
                // Save Button
                Button {
                    //Kiểm tra các điều kiện bắt buộc
                    guard !street.isEmpty,
                          deliveryVM.selectedProvince != nil,
                          deliveryVM.selectedDistrict != nil,
                          deliveryVM.selectedWard != nil
                    //Nếu bất kỳ điều kiện nào sai chạy else
                    else {
                        deliveryVM.errorMessage = "Please fill in all required fields"
                        deliveryVM.showError = true
                        return // Thoát khỏi hành động của nút, không lưu.
                        }
                    //Đảm bảo tất cả trường bắt buộc được điền trước khi lưu.
                    deliveryVM.street = street //Lưu tên đường vào ViewModel để dùng khi gửi API.
                    
                    if mainVM.userObj.id == 0 {
                        deliveryVM.errorMessage = "Please log in to manage addresses"
                        deliveryVM.showError = true
                        return
                    }
                    
                    if isEdit, let editAddress = editAddress { // Nếu isEdit == true và editAddress không nil
                        deliveryVM.serviceCallUpdateAddress(aObj: editAddress, userId: mainVM.userObj.id) {
                            presentationMode.wrappedValue.dismiss() // Đóng view sau khi cập nhật thành công
                        }
                    } else {
                        deliveryVM.serviceCallAddAddress(userId: mainVM.userObj.id) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text(isEdit ? "Update Address" : "Add Address")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                } // Button
                .padding(.horizontal, 25)
                .padding(.bottom, .bottomInsets + 20)
                .background(Color.white)
                
            } // Vstack
        } // Hstack
        
        .onAppear {
            // Reset dữ liệu khi vào form "Add Address"
            if !isEdit {
                deliveryVM.clearAll()
            }
            
            deliveryVM.fetchProvinces()
            
            if isEdit, let editAddress = editAddress { // Update Address
                street = editAddress.street // Điền sẵn tên đường khi chỉnh sửa
                deliveryVM.isDefault = editAddress.isDefault // Đặt trạng thái Toggle "Set as default" khớp với địa chỉ hiện tại
            }
        }
        
        // Điền sẵn tỉnh, quận, phường khi chỉnh sửa địa chỉ trong Groceries
        // Listen for provinces to be fetched || Chạy khi danh sách tỉnh thay đổi (sau khi fetchProvinces hoàn thành)
        // Điền sẵn tỉnh dựa trên editAddress.provinceId và kích hoạt tải quận.
        .onReceive(deliveryVM.$provinces) { provinces in
            guard isEdit, let editAddress = editAddress, !provinces.isEmpty, !isProvinceLoaded else { return } // Chỉ xử lý khi cần chỉnh sửa và có dữ liệu
            deliveryVM.selectedProvince = provinces.first { $0.id == editAddress.provinceId }
            // selectedProvince = ProvinceModel(id: 1, name: "Hà Nội")
            // Tìm tỉnh trong provinces có id khớp với editAddress.provinceI. Gán vào deliveryVM.selectedProvince để Picker tỉnh chọn đúng tỉnh.
            if deliveryVM.selectedProvince != nil {
                deliveryVM.fetchDistricts(provinceId: editAddress.provinceId) // Gọi fetchDistricts để tải quận của tỉnh.
                isProvinceLoaded = true // để không lặp lại.
            }
        }
        // Listen for districts to be fetched
        .onReceive(deliveryVM.$districts) { districts in
            guard isEdit, let editAddress = editAddress, !districts.isEmpty, !isDistrictLoaded else { return }
            deliveryVM.selectedDistrict = districts.first { $0.id == editAddress.districtId }
            if deliveryVM.selectedDistrict != nil {
                deliveryVM.fetchWards(districtId: editAddress.districtId)
                isDistrictLoaded = true
            }
        }
        // Listen for wards to be fetched
        .onReceive(deliveryVM.$wards) { wards in
            guard isEdit, let editAddress = editAddress, !wards.isEmpty, !isWardLoaded else { return }
            deliveryVM.selectedWard = wards.first { $0.id == editAddress.wardId }
            if deliveryVM.selectedWard != nil {
                isWardLoaded = true
            }
        }
        .alert(isPresented: $deliveryVM.showError) {
            Alert(title: Text("Error"), message: Text(deliveryVM.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $deliveryVM.showSuccess) {
            Alert(title: Text("Success"), message: Text(deliveryVM.successMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}

struct AddDeliveryAddressView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddDeliveryAddressView()
                .environmentObject(MainViewModel.shared)
        }
    }
}

/*
-  Giả sử:
 deliveryVM.provinces = [ProvinceModel(id: 1, name: "Hà Nội"), ProvinceModel(id: 2, name: "TP.HCM")].
 deliveryVM.selectedProvince = ProvinceModel(id: 1, name: "Hà Nội") (gán trong .onReceive).
 - Picker tạo các tùy chọn:
 Text("Select Province/City").tag(nil): Tag là nil.
 Text("Hà Nội").tag(ProvinceModel(id: 1, name: "Hà Nội")): Tag là ProvinceModel(id: 1).
 Text("TP.HCM").tag(ProvinceModel(id: 2, name: "TP.HCM")): Tag là ProvinceModel(id: 2).
 Vì selectedProvince = ProvinceModel(id: 1, name: "Hà Nội") khớp với tag của Text("Hà Nội"), Picker hiển thị "Hà Nội" trên form.
 
 
 Ví dụ trực quan:
 Tình huống ban đầu:
 selectedProvince = "TP.HCM" (id: 2).
 selectedDistrict = "Quận 1" (id: 5, thuộc TP.HCM).
 districts chứa danh sách quận của TP.HCM.
 selectedWard = "Phường Bến Nghé" (thuộc Quận 1).
 Người dùng chọn tỉnh mới:
 Chọn selectedProvince = "Hà Nội" (id: 1).
 Nếu không xóa:
 selectedDistrict vẫn là "Quận 1" (id: 5), nhưng "Quận 1" không thuộc Hà Nội.
 fetchDistricts tải danh sách quận của Hà Nội (ví dụ: "Hoàn Kiếm", "Ba Đình"), nhưng selectedDistrict vẫn là "Quận 1", gây lỗi khi gửi API.
 Picker quận có thể hiển thị "Quận 1" (dữ liệu cũ) trong khi danh sách mới là quận của Hà Nội.
 Sau khi xóa:
 selectedDistrict = nil, districts = [], selectedWard = nil, wards = [].
 fetchDistricts(provinceId: 1) tải danh sách quận của Hà Nội (ví dụ: "Hoàn Kiếm", "Ba Đình").
 Người dùng chọn lại "Hoàn Kiếm", rồi tải phường của "Hoàn Kiếm", đảm bảo dữ liệu nhất quán.
 
 
 Ví dụ trực quan
 Giả sử:

 editAddress có: provinceId = 1 (Hà Nội), districtId = 5 (Hoàn Kiếm), wardId = 10 (Phường Hàng Trống).
 Dữ liệu từ API:
 provinces = [ProvinceModel(id: 1, name: "Hà Nội"), ProvinceModel(id: 2, name: "TP.HCM")].
 districts = [DistrictModel(id: 5, name: "Hoàn Kiếm"), DistrictModel(id: 6, name: "Ba Đình")].
 wards = [WardModel(id: 10, name: "Phường Hàng Trống"), WardModel(id: 11, name: "Phường Hàng Bông")].
 Quy trình:
 Tải provinces:
 fetchProvinces trả về [Hà Nội, TP.HCM].
 .onReceive(deliveryVM.$provinces) chạy:
 provinces.first { $0.id == 1 } tìm "Hà Nội".
 deliveryVM.selectedProvince = ProvinceModel(id: 1, name: "Hà Nội").
 Gọi fetchDistricts(provinceId: 1).
 isProvinceLoaded = true.
 Tải districts:
 fetchDistricts trả về [Hoàn Kiếm, Ba Đình].
 .onReceive(deliveryVM.$districts) chạy:
 districts.first { $0.id == 5 } tìm "Hoàn Kiếm".
 deliveryVM.selectedDistrict = DistrictModel(id: 5, name: "Hoàn Kiếm").
 Gọi fetchWards(districtId: 5).
 isDistrictLoaded = true.
 Tải wards:
 fetchWards trả về [Phường Hàng Trống, Phường Hàng Bông].
 .onReceive(deliveryVM.$wards) chạy:
 wards.first { $0.id == 10 } tìm "Phường Hàng Trống".
 deliveryVM.selectedWard = WardModel(id: 10, name: "Phường Hàng Trống").
 isWardLoaded = true.
 Kết quả:
 Picker tỉnh hiển thị "Hà Nội", Picker quận hiển thị "Hoàn Kiếm", Picker phường hiển thị "Phường Hàng Trống" ngay khi view load, phù hợp với editAddress.
 Nếu không có .onReceive?
 Nếu thiếu, các Picker sẽ để trống, người dùng phải chọn lại tỉnh, quận, phường thủ công, dù đang chỉnh sửa một địa chỉ cũ. Điều này làm giảm trải nghiệm người dùng.
 */
