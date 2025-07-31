//
//  NutritionValueModel.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 28/3/25.
//

import SwiftUI


struct NutritionValueModel: Identifiable {
    let id = UUID()
    var nutritionId: Int
    var value: Double

    init(nutritionId: Int, value: Double) {
        self.nutritionId = nutritionId
        self.value = value
    }
}
