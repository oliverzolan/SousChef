//
//  RecipeApiModels.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import Foundation

struct EdamamRecipeResponse: Decodable {
    let hits: [EdamamRecipeHit]
}

struct EdamamRecipeHit: Decodable {
    let recipe: EdamamRecipeModel
}

struct EdamamRecipeModel: Decodable {
    let label: String
    let image: String
    let url: String
    let ingredients: [EdamamRecipeIngredient]
    let totalNutrients: EdamamRecipeNutrients
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

struct EdamamRecipeIngredient: Decodable {
    let text: String
    let quantity: Double
    let measure: String?
    let food: String
    let weight: Double
    let foodCategory: String
    let foodId: String
    let image: String?
}

struct EdamamRecipeNutrients: Decodable {
    let energy: EdamamRecipeNutrient?
    let fat: EdamamRecipeNutrient?
    let saturatedFat: EdamamRecipeNutrient?
    let transFat: EdamamRecipeNutrient?
    let carbs: EdamamRecipeNutrient?
    let fiber: EdamamRecipeNutrient?
    let sugar: EdamamRecipeNutrient?
    let protein: EdamamRecipeNutrient?
    let cholesterol: EdamamRecipeNutrient?
    let sodium: EdamamRecipeNutrient?
    let calcium: EdamamRecipeNutrient?
    let potassium: EdamamRecipeNutrient?
    let iron: EdamamRecipeNutrient?
    let vitaminD: EdamamRecipeNutrient?

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

struct EdamamRecipeNutrient: Decodable {
    let label: String
    let quantity: Double
    let unit: String
}


enum EdamamRecipeCuisineType: String, CaseIterable {
    case american, asian, british, caribbean, centralEurope = "central europe", chinese, easternEurope = "eastern europe"
    case french, indian, italian, japanese, kosher, mediterranean, mexican, middleEastern = "middle eastern"
    case nordic, southAmerican = "south american", southEastAsian = "south east asian"
}

enum EdamamRecipeMealType: String, CaseIterable {
    case breakfast, dinner, lunch, snack, teatime
}

enum EdamamRecipeDiet: String, CaseIterable {
    case balanced, highFiber = "high-fiber", highProtein = "high-protein"
    case lowCarb = "low-carb", lowFat = "low-fat", lowSodium = "low-sodium"
}

enum EdamamRecipeHealth: String, CaseIterable {
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
