//
//  AddNutritionView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 21/4/25.
//

import SwiftUI

struct AddNutritionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var adminVM: AdminViewModel
    @State private var nutritionName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Form để thêm Nutrition mới
                TextField("Nutrition Name", text: $nutritionName)
                    .font(.customfont(.regular, fontSize: 16))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
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
                
                // Danh sách Nutrition hiện có
                VStack(alignment: .leading, spacing: 10) {
                    Text("Existing Nutritions")
                        .font(.customfont(.bold, fontSize: 18))
                        .foregroundColor(.primaryText)
                        .padding(.top, 10)
                    
                    if adminVM.nutritions.isEmpty {
                        Text("No nutritions found")
                            .font(.customfont(.medium, fontSize: 16))
                            .foregroundColor(.secondaryText)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(adminVM.nutritions) { nutrition in
                                    nutritionRowView(for: nutrition)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add New Nutrition")
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
            .onAppear {
                adminVM.fetchNutritions() // Đảm bảo danh sách nutritions được tải khi view xuất hiện
            }
        } // NavigationView
    } // body
    
    private func addNewNutrition() {
        guard !nutritionName.isEmpty else {
            adminVM.errorMessage = "Nutrition name cannot be empty"
            adminVM.showError = true
            return
        }
        
        let parameters: [String: Any] = ["name": nutritionName]
        ServiceCall.post(parameter: parameters as NSDictionary, path: Globs.SV_ADD_NUTRITION) { responseObj in
            if let response = responseObj as? NSDictionary,
               let id = response["id"] as? Int, id > 0 {
                DispatchQueue.main.async {
                    adminVM.fetchNutritions() // Cập nhật danh sách nutritions
                    adminVM.successMessage = "Nutrition added successfully"
                    adminVM.showSuccess = true
                    self.nutritionName = ""
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
    
    private func deleteNutrition(id: Int) {
        let path = Globs.SV_DELETE_NUTRITION.replacingOccurrences(of: "{id}", with: String(id))
        ServiceCall.delete(path: path) { responseObj in
            if responseObj != nil {
                DispatchQueue.main.async {
                    adminVM.fetchNutritions() // Cập nhật danh sách nutritions
                    adminVM.successMessage = "Nutrition deleted successfully"
                    adminVM.showSuccess = true
                }
            } else {
                adminVM.errorMessage = "Failed to delete nutrition"
                adminVM.showError = true
            }
        } failure: { error in
            adminVM.errorMessage = error?.localizedDescription ?? "Network error"
            adminVM.showError = true
        }
    }
    
    private func nutritionRowView(for nutrition: NutritionModel) -> some View {
        HStack {
            Text(nutrition.name)
                .font(.customfont(.medium, fontSize: 16))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Button(action: {
                deleteNutrition(id: nutrition.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
}

#Preview {
    AddNutritionView(adminVM: AdminViewModel())
}
