//
//  AddProductView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 28/3/25.
//

import SwiftUI

struct AddProductView: View {
    @ObservedObject var adminVM: AdminViewModel
    @Binding var product: ProductRequestModel
    @Environment(\.dismiss) var dismiss

    @State private var nutritionValues: [NutritionValueModel] = []
    @State private var newNutritionId: Int = 0
    @State private var newNutritionValue: Double = 0.0

    var body: some View {
        VStack {
            HStack {
                Text(product.id == nil ? "Add Product" : "Edit Product")
                    .font(.customfont(.bold, fontSize: 26))
                    .foregroundColor(.primaryText)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, .topInsets + 20)

            ScrollView {
                VStack(spacing: 20) {
                    customTextField("Name", text: $product.name)
                    customNumberField("Price", value: $product.price)
                    customIntField("Stock", value: $product.stock)
                    customTextField("Unit Name", text: $product.unitName)
                    customTextField("Unit Value", text: $product.unitValue)
                    customTextField("Description", text: Binding(
                        get: { product.description ?? "" },
                        set: { product.description = $0.isEmpty ? nil : $0 }
                    ))
                    customTextField("Image URL", text: Binding(
                        get: { product.imageUrl ?? "" },
                        set: { product.imageUrl = $0.isEmpty ? nil : $0 }
                    ))
                    customPicker("Category", selection: Binding(
                        get: { product.categoryId },
                        set: { product.categoryId = $0 }
                    ), items: adminVM.categories) { category in
                        Text(category.name)
                    }
                    customPicker("Brand", selection: Binding(
                        get: { product.brandId },
                        set: { product.brandId = $0 }
                    ), items: adminVM.brands) { brand in
                        Text(brand.name)
                    }
                    customNumberField("Offer Price", value: Binding(
                        get: { product.offerPrice ?? 0.0 },
                        set: { product.offerPrice = $0 == 0.0 ? nil : $0 }
                    ))
                    customIntField("Average Rating", value: Binding(
                        get: { product.avgRating ?? 0 },
                        set: { product.avgRating = $0 == 0 ? nil : $0 }
                    ))
                    customDatePicker("Start Date", selection: Binding(
                        get: { product.startDate ?? Date() },
                        set: { product.startDate = $0 }
                    ))
                    customDatePicker("End Date", selection: Binding(
                        get: { product.endDate ?? Date() },
                        set: { product.endDate = $0 }
                    ))

                    // Thêm phần nhập nutritionValues
                    VStack(alignment: .leading) {
                        Text("Nutrition Values")
                            .font(.customfont(.semibold, fontSize: 16))
                            .foregroundColor(.primaryText)

                        ForEach(nutritionValues.indices, id: \.self) { index in
                            HStack {
                                TextField("Nutrition ID", value: $nutritionValues[index].nutritionId, formatter: NumberFormatter.integerFormatter)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                                TextField("Value", value: $nutritionValues[index].value, formatter: NumberFormatter.currencyFormatter)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                                Button(action: {
                                    nutritionValues.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        HStack {
                            TextField("New Nutrition ID", value: $newNutritionId, formatter: NumberFormatter.integerFormatter)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                            TextField("New Value", value: $newNutritionValue, formatter: NumberFormatter.currencyFormatter)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                            Button(action: {
                                nutritionValues.append(NutritionValueModel(nutritionId: newNutritionId, value: newNutritionValue))
                                newNutritionId = 0
                                newNutritionValue = 0.0
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, .bottomInsets + 20)
            }

            Button(action: {
                product.nutritionValues = nutritionValues.isEmpty ? nil : nutritionValues
                saveProduct()
            }) {
                Text(product.id == nil ? "Save Product" : "Update Product")
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            nutritionValues = product.nutritionValues ?? []
        }
        .alert(isPresented: $adminVM.showError) {
            Alert(
                title: Text(Globs.AppName),
                message: Text(adminVM.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $adminVM.showSuccess) {
            Alert(
                title: Text(Globs.AppName),
                message: Text(adminVM.successMessage),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }

    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    private func customNumberField(_ placeholder: String, value: Binding<Double>) -> some View {
        TextField(placeholder, value: value, formatter: NumberFormatter.currencyFormatter)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .keyboardType(.decimalPad)
            .textFieldStyle(PlainTextFieldStyle())
    }

    private func customIntField(_ placeholder: String, value: Binding<Int>) -> some View {
        TextField(placeholder, value: value, formatter: NumberFormatter.integerFormatter)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .keyboardType(.numberPad)
            .textFieldStyle(PlainTextFieldStyle())
    }

    private func customPicker<T: Identifiable>(_ title: String, selection: Binding<Int?>, items: [T], content: @escaping (T) -> some View) -> some View {
        Picker(title, selection: selection) {
            Text("None").tag(nil as Int?)
            ForEach(items) { item in
                content(item).tag((item as? CategoryModel)?.id ?? (item as? BrandModel)?.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .font(.customfont(.regular, fontSize: 16))
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    private func customDatePicker(_ title: String, selection: Binding<Date>) -> some View {
        DatePicker(title, selection: selection, displayedComponents: .date)
            .font(.customfont(.regular, fontSize: 16))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    private func saveProduct() {
        // Đảm bảo startDate và endDate không nil
        if product.startDate == nil {
            product.startDate = Date()
        }
        if product.endDate == nil {
            product.endDate = Date()
        }

        if product.id == nil {
            adminVM.addProduct(product: product) { success in
                if !success {
                    adminVM.showError = true
                }
            }
        } else {
            adminVM.updateProduct(id: product.id!, product: product) { success in
                if !success {
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
        formatter.minimum = 0
        return formatter
    }()
    
    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 0
        return formatter
    }()
}

#Preview {
    AddProductView(
        adminVM: AdminViewModel(),
        product: .constant(ProductRequestModel(
            name: "",
            price: 0.0,
            stock: 0,
            unitName: "",
            unitValue: ""
        ))
    )
}
