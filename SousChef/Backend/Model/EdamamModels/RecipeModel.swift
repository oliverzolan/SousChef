//
//  RecipeApiModels.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import Foundation

struct EdamamRecipeResponse: Codable {
    let hits: [EdamamRecipeHit]
    let from: Int?
    let to: Int?
    let count: Int?
    let _links: EdamamLinks?
    
    enum CodingKeys: String, CodingKey {
        case hits, from, to, count
        case _links = "_links"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        hits = try container.decode([EdamamRecipeHit].self, forKey: .hits)
        from = try container.decodeIfPresent(Int.self, forKey: .from)
        to = try container.decodeIfPresent(Int.self, forKey: .to)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        
        _links = try? container.decodeIfPresent(EdamamLinks.self, forKey: ._links)
    }
}

struct EdamamLinks: Codable {
    let next: EdamamLink?
}

struct EdamamLink: Codable {
    let href: String
    let title: String?
}

struct EdamamRecipeHit: Codable {
    let recipe: EdamamRecipeModel
}

struct EdamamRecipeModel: Codable {
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
    let dietLabels: [String]?       
    let healthLabels: [String]?

    private enum CodingKeys: String, CodingKey {
        case label, image, url, ingredients = "ingredients"
        case totalNutrients, calories, totalWeight, cuisineType, mealType, dishType
        case dietLabels, healthLabels
    }
}

struct EdamamRecipeIngredient: Codable {
    let text: String
    let quantity: Double
    let measure: String?
    let food: String
    let weight: Double
    let foodCategory: String?
    let foodId: String?
    let image: String?
    let parsed: [EdamamParsedFood]?
}

struct EdamamParsedFood: Codable {
    let food: String
    let foodId: String
    let measure: String?
    let quantity: Double?
    let weight: Double?
}

struct EdamamRecipeNutrients: Codable {
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

struct EdamamRecipeNutrient: Codable {
    let label: String
    let quantity: Double
    let unit: String
}


enum EdamamRecipeCuisineType: String, CaseIterable, Codable {
    case american, asian, british, caribbean, centralEurope = "central europe", chinese, easternEurope = "eastern europe"
    case french, indian, italian, japanese, kosher, mediterranean, mexican, middleEastern = "middle eastern"
    case nordic, southAmerican = "south american", southEastAsian = "south east asian"
}

enum EdamamRecipeMealType: String, CaseIterable, Codable {
    case breakfast, dinner, lunch, snack, teatime
}

enum EdamamRecipeDiet: String, CaseIterable, Codable {
    case balanced, highFiber = "high-fiber", highProtein = "high-protein"
    case lowCarb = "low-carb", lowFat = "low-fat", lowSodium = "low-sodium"
}

enum EdamamRecipeHealth: String, CaseIterable, Codable {
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
