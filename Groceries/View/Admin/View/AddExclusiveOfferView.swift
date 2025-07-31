//
//  AddExclusiveOfferView.swift
//  Groceries_Shop
//
//  Created by Nguyễn Toàn on 4/11/25.
//

import SwiftUI

struct AddExclusiveOfferView: View {
    @ObservedObject var adminVM: AdminViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var discountPercentage: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // Mặc định 7 ngày sau
    @State private var selectedProduct: ProductModel? = nil
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Offer Details")) {
                TextField("Discount Percentage (%)", text: $discountPercentage)
                    .keyboardType(.decimalPad)
                    .onChange(of: discountPercentage) { _ in validateForm() }
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .onChange(of: startDate) { _ in validateForm() }
                
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .onChange(of: endDate) { _ in validateForm() }
            }// sec
            
            Section(header: Text("Select Product")) {
                if adminVM.productList.isEmpty {
                    Text("No products available")
                        .foregroundColor(.gray)
                } else {
                    Picker("Product", selection: $selectedProduct) {
                        Text("Select a product").tag(nil as ProductModel?)
                        ForEach(adminVM.productList) { product in
                            Text(product.name).tag(product as ProductModel?)
                        }
                    }
                    .onChange(of: selectedProduct) { _ in validateForm() }
                }
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                Button(action: {
                    saveExclusiveOffer()
                }) {
                    Text("Save")
                        .font(.customfont(.bold, fontSize: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
            }
        } // form
        .navigationTitle("Add Exclusive Offer")
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
                .foregroundColor(.red)
        })
        .onAppear {
            validateForm()
        }
    }
    
    private var isFormValid: Bool {
        guard let discount = Double(discountPercentage), discount > 0, discount <= 100 else {
            errorMessage = "Discount percentage must be between 0 and 100"
            return false
        }
        
        if startDate >= endDate {
            errorMessage = "Start date must be before end date"
            return false
        }
        
        if selectedProduct == nil {
            errorMessage = "Please select a product"
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    private func validateForm() {
        _ = isFormValid
    }
    
    private func saveExclusiveOffer() {
        guard let discount = Double(discountPercentage), let product = selectedProduct else { return }
        
        adminVM.addExclusiveOffer(
            discountPercentage: discount,
            startDate: startDate,
            endDate: endDate,
            productId: product.id
        ) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        AddExclusiveOfferView(adminVM: AdminViewModel())
    }
}
