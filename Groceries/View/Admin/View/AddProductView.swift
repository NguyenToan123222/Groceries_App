//
//  AddProductView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 28/3/25.
//

import SwiftUI
 // nhớ hỏi làm sao add img từ máy
struct AddProductView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var adminVM: AdminViewModel
    @State var product: ProductRequestModel
    @State private var nutritionValues: [NutritionValueModel] = []
    @State private var showingAddNutritionForm = false
    @State private var newNutritionName = ""
    @State private var enableNutritionValues = false // Toggle để bật/tắt Nutrition Values

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    // Product Name
                    customTextField("Product Name", text: $product.name)
                    
                    // Description
                    customTextField("Description", text: Binding(
                        get: { product.description ?? "" },
                        /*LẤY gtrị: product.description = nil → ""; product.description = "Fresh fruit" → "Fresh fruit"
                         
                         Giá trị nhập ($0)
                         ĐẶT gtrị: Nhập "" → product.description = nil; nhập "Fresh fruit" → product.description = "Fresh fruit".
                         */
                        set: { product.description = $0.isEmpty ? nil : $0 }
                    ))
                    
                    // Image URL
                    customTextField("Image URL", text: Binding(
                        get: { product.imageUrl ?? "" },
                        set: { product.imageUrl = $0.isEmpty ? nil : $0 }
                    ))
                    
                    // Price
                    customNumberField("Price", value: $product.price)
                    
                    // Offer Price
                    customNumberField("Offer Price", value: Binding(
                        get: { product.offerPrice ?? 0.0 },
                        set: { product.offerPrice = $0 > 0 ? $0 : nil }
                    ))
                    
                    // Stock
                    customIntField("Stock", value: $product.stock)
                    
                    // Unit Name
                    customTextField("Unit Name", text: $product.unitName)
                    
                    // Unit Value
                    customTextField("Unit Value", text: $product.unitValue)
                    
                    // Category Picker
                    customPicker("Category", selection: $product.categoryId, items: adminVM.categories) { category in
                        Text(category.name).tag(category.id as Int?)
                    }
                    
                    // Brand Picker
                    customPicker("Brand", selection: $product.brandId, items: adminVM.brands) { brand in
                        Text(brand.name).tag(brand.id as Int?)
                    }
                    
                    // Average Rating
                    customNumberField("Average Rating", value: Binding(
                        get: { product.avgRating ?? 0.0 },
                        set: { product.avgRating = $0 > 0 ? $0 : nil }
                    ))
                    
                    // Start Date
                    DatePicker("Start Date", selection: Binding(
                        get: { product.startDate ?? Date() },
                        set: { product.startDate = $0 }
                    ), displayedComponents: [.date])
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    // End Date
                    DatePicker("End Date", selection: Binding(
                        get: { product.endDate ?? Date() },
                        set: { product.endDate = $0 }
                    ), displayedComponents: [.date])
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    // Toggle để bật/tắt Nutrition Values
                    Toggle(isOn: $enableNutritionValues) {
                        Text("Add Nutrition Values")
                            .font(.customfont(.bold, fontSize: 18))
                    }
                    .padding(.horizontal)
                    
                    // Nutrition Values Section (Hiển thị nếu toggle bật)
                    // nutritionValues = [{nutritionId: 12345, value: 52.0}, {nutritionId: 67890, value: 100.0}] (từ "Apples" và "Chicken breast").
                    if enableNutritionValues {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(nutritionValues.indices, id: \.self) { index in // index = 0, index = 1...
                                // adminVM.nutritions = [NutritionModel(id: 1, name: "Vitamin C"), NutritionModel(id: 2, name: "Protein")].
                                HStack {
                                    /*
                                     Nếu nutritionValues = [{nutritionId: 12345, value: 52.0}]:
                                     Lần lặp đầu (index = 0): $nutritionValues[0].nutritionId liên kết với 12345.
                                     
                                     Nếu adminVM.nutritions = [NutritionModel(id: 12345, name: "Apples, raw, with skin"), NutritionModel(id: 67890, name: "Chicken breast")]:
                                     - Lần lặp 1: nutrition = {id: 12345, name: "Apples, raw, with skin"}
                                     → Text("Apples, raw, with skin").tag(12345).
                                     - Lần lặp 2: nutrition = {id: 67890, name: "Chicken breast"}
                                     → Text("Chicken breast").tag(67890).
                                     */
                                    Picker("Nutrition", selection: $nutritionValues[index].nutritionId) {
                                        ForEach(adminVM.nutritions) { nutrition in
                                            Text(nutrition.name).tag(nutrition.id)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .font(.customfont(.regular, fontSize: 16))
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    .tint(.black)
                                    
                                    customNumberField("Value", value: $nutritionValues[index].value)
                                    
                                    Button(action: {
                                        nutritionValues.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                } // HStack
                            } // For
                            
                            // Nút thêm Nutrition Value
                            Button(action: {
                                if let firstNutritionId = adminVM.nutritions.first?.id {
                                    nutritionValues.append(NutritionValueModel(nutritionId: firstNutritionId, value: 0.0))
                                } else {
                                    adminVM.errorMessage = "No nutritions available. Please add a new nutrition first."
                                    adminVM.showError = true
                                }
                            }) {
                                Text("Add Nutrition Value")
                                    .font(.customfont(.medium, fontSize: 16))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            // Nút thêm Nutrition mới
                            Button(action: {
                                showingAddNutritionForm = true
                            }) {
                                Text("Add New Nutrition")
                                    .font(.customfont(.medium, fontSize: 16))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        } // Vstack
                    } // if
                    
                    // Save Button
                    Button(action: {
                        saveProduct()
                    }) {
                        Text("Save")
                            .font(.customfont(.bold, fontSize: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle(product.id == nil ? "Add Product" : "Edit Product")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert(isPresented: $adminVM.showError) {
                Alert(title: Text("Error"), message: Text(adminVM.errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $adminVM.showSuccess) {
                Alert(title: Text("Success"), message: Text(adminVM.successMessage), dismissButton: .default(Text("OK")) {
                    dismiss()
                })
            }
            .sheet(isPresented: $showingAddNutritionForm) {
                addNutritionForm
            }
            .onAppear {
                nutritionValues = product.nutritionValues ?? []// edit 
                if product.categoryId == nil, let firstCategory = adminVM.categories.first {
                    product.categoryId = firstCategory.id
                }
                // product.categoryId = nil, adminVM.categories = [CategoryModel(id: 1, name: "Fruits"), CategoryModel(id: 2, name: "Vegetables")] → firstCategory = {id: 1, name: "Fruits"}, product.categoryId = 1.
                
                if product.brandId == nil, let firstBrand = adminVM.brands.first {
                    product.brandId = firstBrand.id
                }
                // product.brandId = nil, adminVM.brands = [BrandModel(id: 101, name: "Organic"), BrandModel(id: 102, name: "Generic")] → firstBrand = {id: 101, name: "Organic"}, product.brandId = 101.
                
                // Nếu có nutrition values từ trước, bật toggle
                if !nutritionValues.isEmpty {
                    enableNutritionValues = true
                }
            }
        }
    }
    
    private var addNutritionForm: some View {
        NavigationView {
            VStack(spacing: 15) {
                TextField("Nutrition Name", text: $newNutritionName)
                    .font(.customfont(.regular, fontSize: 16))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1)) // border
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button(action: {
                    addNewNutrition()
                }) {
                    Text("Save Nutrition")
                        .font(.customfont(.bold, fontSize: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } // Vstack
            .padding()
            .navigationTitle("Add New Nutrition")
            .navigationBarItems(trailing: Button(action: {
                showingAddNutritionForm = false
                newNutritionName = ""
            }) {
                Image(systemName: "xmark.circle.fill") // Icon dấu X
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            })
        }
    }
    
    private func addNewNutrition() {
        guard !newNutritionName.isEmpty else {
            adminVM.errorMessage = "Nutrition name cannot be empty"
            adminVM.showError = true
            return
        }
        
        let parameters: [String: Any] = ["name": newNutritionName]
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_ADD_NUTRITION) { responseObj in
            if let response = responseObj as? NSDictionary,
               let id = response["id"] as? Int, id > 0 { // response = ["id": 201, "status": "success"] → id = 201, id > 0
                DispatchQueue.main.async {
                    adminVM.fetchNutritions()
                    adminVM.successMessage = "Nutrition added successfully"
                    adminVM.showSuccess = true
                    self.showingAddNutritionForm = false
                    self.newNutritionName = ""
                }
            } else {
                adminVM.errorMessage = "Failed to add nutrition"
                adminVM.showError = true
            }
        } failure: { error in
            adminVM.errorMessage = error?.localizedDescription ?? "Network error"
            adminVM.showError = true
        }
    }

    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    
    private func customNumberField(_ placeholder: String, value: Binding<Double>) -> some View {
        TextField(placeholder, value: value, formatter: NumberFormatter.currencyFormatter)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .keyboardType(.decimalPad)
            .textFieldStyle(PlainTextFieldStyle())
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    
    private func customIntField(_ placeholder: String, value: Binding<Int>) -> some View {
        TextField(placeholder, value: value, formatter: NumberFormatter.integerFormatter)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .keyboardType(.numberPad)
            .textFieldStyle(PlainTextFieldStyle())
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    /*
     customPicker("Category", selection: $product.categoryId, items: adminVM.categories) { category in
         Text(category.name).tag(category.id as Int?)
     }
     */
    private func customPicker<T: Identifiable>(_ title: String, selection: Binding<Int?>, items: [T], content: @escaping (T) -> some View) -> some View {
        Picker(title, selection: selection) {
            Text("None").tag(nil as Int?)
            ForEach(items) { item in
                content(item)
                    .tag((item as? CategoryModel)?.id ?? (item as? BrandModel)?.id ?? 0) // .tag(1)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .font(.customfont(.regular, fontSize: 16))
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .tint(.black)
    }
    
    private func saveProduct() {
        if product.name.isEmpty || product.unitName.isEmpty || product.unitValue.isEmpty {
            adminVM.errorMessage = "Product Name, Unit Name, and Unit Value are required"
            adminVM.showError = true
            return
        }
        
        if product.price <= 0 || product.price.isNaN {
            adminVM.errorMessage = "Price must be greater than 0 and a valid number"
            adminVM.showError = true
            return
        }
        if product.stock < 0 {
            adminVM.errorMessage = "Stock must be 0 or greater"
            adminVM.showError = true
            return
        }
        if let offerPrice = product.offerPrice, (offerPrice <= 0 || offerPrice.isNaN) {
            adminVM.errorMessage = "Offer Price must be greater than 0 and a valid number"
            adminVM.showError = true
            return
        }
        if let avgRating = product.avgRating, (avgRating < 0 || avgRating > 5 || avgRating.isNaN) {
            adminVM.errorMessage = "Average Rating must be between 0 and 5 and a valid number"
            adminVM.showError = true
            return
        }
        
        // Chỉ validate nutrition values nếu toggle được bật
        if enableNutritionValues {
            for nutrition in nutritionValues {
                if nutrition.nutritionId <= 0 {
                    adminVM.errorMessage = "Nutrition ID must be a positive integer"
                    adminVM.showError = true
                    return
                }
                if nutrition.value <= 0 || nutrition.value.isNaN {
                    adminVM.errorMessage = "Nutrition Value must be greater than 0 and a valid number"
                    adminVM.showError = true
                    return
                }
            }
        }
        
        if product.startDate == nil {
            product.startDate = Date()
        }
        if product.endDate == nil {
            product.endDate = Date()
        }
        
        // Gán nutrition values nếu toggle được bật
        product.nutritionValues = enableNutritionValues && !nutritionValues.isEmpty ? nutritionValues : nil
        
        if product.id == nil {
            adminVM.addProduct(product: product) { success in
                if success {
                    dismiss()
                } else {
                    adminVM.showError = true
                }
            }
        } else {
            adminVM.updateProduct(id: product.id!, product: product) { success in
                if success {
                    dismiss()
                } else {
                    adminVM.showError = true
                }
            }
        }
    }
}

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView(
            adminVM: AdminViewModel(),
            product: ProductRequestModel(
                id: nil,
                name: "",
                price: 0.0,
                stock: 0,
                unitName: "",
                unitValue: "",
                description: nil,
                imageUrl: nil,
                categoryId: nil,
                brandId: nil,
                offerPrice: nil,
                avgRating: nil,
                startDate: nil,
                endDate: nil,
                nutritionValues: nil
            )
        )
    }
}
