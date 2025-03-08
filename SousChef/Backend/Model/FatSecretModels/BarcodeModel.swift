//
//  Barcode.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/7/25.
//

import Foundation

struct EdamamBarcodeResponse: Decodable {
    let hints: [EdamamBarcodeHint]
}

struct EdamamBarcodeHint: Decodable {
    let food: BarcodeModel
}

struct BarcodeModel: Identifiable, Hashable, Decodable {
    var id: String { foodId }
    let foodId: String
    let label: String // name
    let brand: String?
    let category: String?
    let image: String?
    let nutrients: EdamamBarcodeNutrient?
    
    func hash(into hasher: inout Hasher){
        hasher.combine(foodId)
    }

    static func == (lhs: BarcodeModel, rhs: BarcodeModel) -> Bool {
        return lhs.foodId == rhs.foodId
    }
}

struct EdamamBarcodeNutrient: Decodable {
    let energy: Double?
    let protein: Double?
    let fat: Double?
    let carbs: Double?
    let fiber: Double?
    let sodium: Double?
    let cholesterol: Double?
    let sugar: Double?
    let transFat: Double?
    let saturatedFat: Double?
    let potassium: Double?
    let iron: Double?
    let niacin: Double?
    let vitaminB6: Double?
    let vitaminB12: Double?
    let vitaminD: Double?

    private enum CodingKeys: String, CodingKey {
        case energy = "ENERC_KCAL"
        case protein = "PROCNT"
        case fat = "FAT"
        case carbs = "CHOCDF"
        case fiber = "FIBTG"
        case sodium = "NA"
        case cholesterol = "CHOLE"
        case sugar = "SUGAR"
        case transFat = "FATRN"
        case saturatedFat = "FASAT"
        case potassium = "K"
        case iron = "FE"
        case niacin = "NIA"
        case vitaminB6 = "VITB6A"
        case vitaminB12 = "VITB12"
        case vitaminD = "VITD"
    }
}
