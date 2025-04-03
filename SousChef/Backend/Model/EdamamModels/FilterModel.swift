import Foundation

struct FilterModel {
    var cuisineType: String?
    var mealType: String?
    var dietType: String?
    var healthType: String?
    var maxTime: Int?
    
    var isEmpty: Bool {
        return cuisineType == nil && 
               mealType == nil && 
               dietType == nil && 
               healthType == nil && 
               maxTime == nil
    }
    
    mutating func reset() {
        cuisineType = nil
        mealType = nil
        dietType = nil
        healthType = nil
        maxTime = nil
    }
    
    // Filter categories for UI
    static let categories = ["Cuisine", "Meal", "Diet", "Health", "Time"]
    
    // Filter options
    static let cuisineTypes = [
        "American", "Asian", "British", "Caribbean", "Central Europe", "Chinese", 
        "Eastern Europe", "French", "Greek", "Indian", "Italian", "Japanese", 
        "Korean", "Mediterranean", "Mexican", "Middle Eastern", "Nordic", 
        "South American", "South East Asian"
    ]
    
    static let mealTypes = ["Breakfast", "Brunch", "Lunch/Dinner", "Snack"]
    
    static let dietTypes = [
        "Balanced", "High-Fiber", "High-Protein", "Low-Carb", 
        "Low-Fat", "Low-Sodium"
    ]
    
    static let healthTypes = [
        "Alcohol-Free", "Dairy-Free", "Egg-Free", "Gluten-Free", 
        "Keto-Friendly", "Low-Sugar", "Paleo", "Pescatarian", 
        "Vegan", "Vegetarian"
    ]
    
    static let cookTimes = [15, 30, 45, 60, 90, 120]
    
    // Check if a specific filter category is active
    func isCategoryActive(_ category: String) -> Bool {
        switch category {
        case "Cuisine":
            return cuisineType != nil
        case "Meal":
            return mealType != nil
        case "Diet":
            return dietType != nil
        case "Health":
            return healthType != nil
        case "Time":
            return maxTime != nil
        default:
            return false
        }
    }
} 