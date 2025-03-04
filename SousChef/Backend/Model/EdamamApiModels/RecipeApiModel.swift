//
//  RecipeApiModels.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import Foundation

struct RecipeResponse: Decodable {
    let hits: [Hit]
}

struct Hit: Decodable {
    let recipe: RecipeModel
}

struct RecipeModel: Decodable {
    let uri: String
    let label: String
    let image: String
    let url: String
    let ingredients: [Ingredient]
    let totalNutrients: Nutrients
    let calories: Double
    let totalWeight: Double
    let cuisineType: [String]?
    let mealType: [String]?
    let dishType: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case label, image, url, ingredients = "ingredients"
        case totalNutrients, calories, totalWeight, cuisineType, mealType, dishType
    }
}

struct Ingredient: Decodable {
    let text: String
    let quantity: Double
    let measure: String?
    let food: String
    let weight: Double
    let foodCategory: String
    let foodId: String
    let image: String?
}

struct Nutrients: Decodable {
    let energy: Nutrient?
    let fat: Nutrient?
    let saturatedFat: Nutrient?
    let transFat: Nutrient?
    let carbs: Nutrient?
    let fiber: Nutrient?
    let sugar: Nutrient?
    let protein: Nutrient?
    let cholesterol: Nutrient?
    let sodium: Nutrient?
    let calcium: Nutrient?
    let potassium: Nutrient?
    let iron: Nutrient?
    let vitaminD: Nutrient?

    private enum CodingKeys: String, CodingKey {
        case energy = "ENERC_KCAL"
        case fat = "FAT"
        case saturatedFat = "FASAT"
        case transFat = "FATRN"
        case carbs = "CHOCDF"
        case fiber = "FIBTG"
        case sugar = "SUGAR"
        case protein = "PROCNT"
        case cholesterol = "CHOLE"
        case sodium = "NA"
        case calcium = "CA"
        case potassium = "K"
        case iron = "FE"
        case vitaminD = "VITD"
    }
}

struct Nutrient: Decodable {
    let label: String
    let quantity: Double
    let unit: String
}


enum CuisineType: String, CaseIterable {
    case american, asian, british, caribbean, centralEurope = "central europe", chinese, easternEurope = "eastern europe"
    case french, indian, italian, japanese, kosher, mediterranean, mexican, middleEastern = "middle eastern"
    case nordic, southAmerican = "south american", southEastAsian = "south east asian"
}

enum MealType: String, CaseIterable {
    case breakfast, dinner, lunch, snack, teatime
}

enum Diet: String, CaseIterable {
    case balanced, highFiber = "high-fiber", highProtein = "high-protein"
    case lowCarb = "low-carb", lowFat = "low-fat", lowSodium = "low-sodium"
}

enum Health: String, CaseIterable {
    case alcoholCocktail = "alcohol-cocktail", alcoholFree = "alcohol-free", celeryFree = "celery-free"
    case crustaceanFree = "crustacean-free", dairyFree = "dairy-free", dash = "DASH"
    case eggFree = "egg-free", fishFree = "fish-free", fodmapFree = "fodmap-free"
    case glutenFree = "gluten-free", immunoSupportive = "immuno-supportive", ketoFriendly = "keto-friendly"
    case kidneyFriendly = "kidney-friendly", kosher, lowFatAbs = "low-fat-abs", lowPotassium = "low-potassium"
    case lowSugar = "low-sugar", lupineFree = "lupine-free", mediterranean, molluskFree = "mollusk-free"
    case mustardFree = "mustard-free", noOilAdded = "no-oil-added", paleo, peanutFree = "peanut-free"
    case pescatarian, porkFree = "pork-free", redMeatFree = "red-meat-free", sesameFree = "sesame-free"
    case shellfishFree = "shellfish-free", soyFree = "soy-free", sugarConscious = "sugar-conscious"
    case sulfiteFree = "sulfite-free", treeNutFree = "tree-nut-free", vegan, vegetarian, wheatFree = "wheat-free"
}
