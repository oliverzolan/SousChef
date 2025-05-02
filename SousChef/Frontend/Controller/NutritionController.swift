import Foundation

class NutritionController: ObservableObject {
    @Published var isLoading: Bool = false
    
    // Keep this for backward compatibility
    private let awsInternalIngredientsComponent: AWSInternalIngredientsComponent
    
    init(userSession: UserSession) {
        self.awsInternalIngredientsComponent = AWSInternalIngredientsComponent(userSession: userSession)
    }
    
    @MainActor
    func fetchIngredientNutrition(for id: String, completion: @escaping (Result<AWSIngredientNutritionModel, Error>) -> Void) {
        isLoading = true
        
        // Use local data instead of API call
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            // Get the food name - if id looks like an edamamID, use a generic name
            let foodName = id.starts(with: "food_") ? "ingredient" : id
            
            // Get nutrition data from local data
            let (calories, protein, carbs, fat) = self?.getFoodNutrition(for: foodName.lowercased()) ?? (120, 5, 10, 5)
            let (cholesterol, sodium, potassium) = self?.getAdditionalNutrition(for: foodName.lowercased()) ?? (20, 80, 200)
            let foodCategory = NutritionController.getFoodCategory(for: foodName.lowercased())
            
            // Create nutrition model with local data
            let nutrition = AWSIngredientNutritionModel(
                edamamFoodId: id,
                name: foodName,
                foodCategory: foodCategory,
                quantityType: "g",
                experiationDuration: 7,
                fat: Double(fat),
                cholesterol: Double(cholesterol),
                sodium: Double(sodium),
                potassium: Double(potassium),
                carbohydrate: Double(carbs),
                protein: Double(protein),
                calorie: Double(calories),
                quantity: 100.0
            )
            
            completion(.success(nutrition))
        }
    }
    
    // Helper functions to get nutrition data locally - same functions as in NutritionFactsPopup
    private func getFoodNutrition(for name: String) -> (calories: Int, protein: Int, carbs: Int, fat: Int) {
        let nutrition: [String: (calories: Int, protein: Int, carbs: Int, fat: Int)] = [
            // Vegetables
            "tomato": (18, 1, 4, 0),
            "broccoli": (34, 3, 7, 0),
            "carrot": (41, 1, 10, 0),
            "spinach": (23, 3, 4, 0),
            "kale": (49, 4, 9, 1),
            "potato": (77, 2, 17, 0),
            "garlic": (149, 6, 33, 1),
            "bell pepper": (30, 1, 7, 0),
            "corn": (86, 3, 19, 1),
            "endive": (17, 1, 3, 0),
            "lettuce": (15, 1, 3, 0),
            "celery": (16, 1, 3, 0),
            "onion": (40, 1, 9, 0),
            "green bean": (31, 2, 7, 0),
            "asparagus": (20, 2, 4, 0),
            "cucumber": (15, 1, 3, 0),
            "eggplant": (25, 1, 6, 0),
            "zucchini": (17, 1, 3, 0),
            
            // Fruits
            "apple": (52, 0, 14, 0),
            "banana": (89, 1, 23, 0),
            "orange": (47, 1, 12, 0),
            "pineapple": (50, 1, 13, 0),
            "grape": (69, 1, 18, 0),
            "strawberry": (32, 1, 8, 0),
            "blueberry": (57, 1, 14, 0),
            "avocado": (160, 2, 9, 15),
            "coconut": (354, 3, 15, 33),
            "mango": (60, 1, 15, 0),
            "watermelon": (30, 1, 8, 0),
            "kiwi": (61, 1, 15, 1),
            "peach": (39, 1, 10, 0),
            "lemon": (29, 1, 9, 0),
            
            // Meats
            "chicken": (165, 31, 0, 4),
            "beef": (250, 26, 0, 15),
            "pork": (242, 26, 0, 14),
            "bacon": (541, 37, 1, 42),
            "ham": (145, 21, 1, 5),
            "turkey": (189, 29, 0, 7),
            "sausage": (301, 16, 3, 25),
            "lamb": (294, 25, 0, 21),
            "steak": (271, 25, 0, 19),
            "ground beef": (250, 26, 0, 15),
            "duck": (337, 19, 0, 28),
            
            // Seafood
            "salmon": (208, 20, 0, 13),
            "tuna": (109, 24, 0, 1),
            "shrimp": (119, 24, 0, 1),
            "crab": (97, 19, 0, 2),
            "lobster": (89, 19, 0, 1),
            "cod": (82, 18, 0, 1),
            "tilapia": (128, 26, 0, 3),
            "trout": (190, 27, 0, 8),
            "halibut": (111, 23, 0, 2),
            
            // Specific cuts
            "chicken breast": (165, 31, 0, 4),
            "chicken wings": (290, 27, 0, 19),
            
            // Dairy
            "milk": (60, 3, 5, 3),
            "cheese": (402, 25, 3, 33),
            "yogurt": (59, 4, 5, 0),
            "butter": (717, 1, 0, 81),
            "cream": (340, 2, 7, 33),
            
            // Grains
            "rice": (130, 3, 28, 0),
            "bread": (265, 9, 49, 3),
            "pasta": (131, 5, 25, 1),
            "oat": (389, 17, 66, 7),
            "quinoa": (120, 4, 21, 2),
            
            // Other
            "egg": (143, 13, 1, 10),
            "honey": (304, 0, 82, 0),
            "olive oil": (884, 0, 0, 100),
            "sugar": (387, 0, 100, 0),
            "chocolate": (546, 5, 61, 31),
            "peanut butter": (588, 25, 20, 50)
        ]
        
        // Check for exact match first
        if let exact = nutrition[name] {
            return exact
        }
        
        // Check for partial match
        for (key, value) in nutrition {
            if name.contains(key) || key.contains(name) {
                return value
            }
        }
        
        // Return standard values if no match found
        return (120, 5, 10, 5)
    }
    
    // Get additional nutrition info
    private func getAdditionalNutrition(for name: String) -> (cholesterol: Int, sodium: Int, potassium: Int) {
        let additionalNutrition: [String: (cholesterol: Int, sodium: Int, potassium: Int)] = [
            // Vegetables
            "tomato": (0, 5, 237),
            "broccoli": (0, 33, 316),
            "carrot": (0, 69, 320),
            "spinach": (0, 79, 558),
            "kale": (0, 53, 491),
            "potato": (0, 6, 421),
            "bell pepper": (0, 4, 211),
            "corn": (0, 15, 270),
            "cucumber": (0, 2, 147),
            "onion": (0, 4, 146),
            "garlic": (0, 17, 401),
            "zucchini": (0, 8, 295),
            "eggplant": (0, 2, 229),
            "asparagus": (0, 2, 202),
            
            // Fruits
            "apple": (0, 1, 107),
            "banana": (0, 1, 358),
            "orange": (0, 0, 181),
            "avocado": (0, 7, 485),
            "pineapple": (0, 1, 109),
            "grape": (0, 2, 191),
            "strawberry": (0, 1, 153),
            "blueberry": (0, 1, 77),
            "watermelon": (0, 2, 112),
            "peach": (0, 0, 190),
            "kiwi": (0, 3, 312),
            "mango": (0, 2, 168),
            "lemon": (0, 2, 138),
            
            // Meats
            "chicken": (85, 65, 256),
            "beef": (75, 66, 318),
            "pork": (80, 65, 340),
            "bacon": (110, 1900, 240),
            "ham": (53, 1203, 270),
            "turkey": (65, 68, 252),
            "sausage": (65, 800, 315),
            "lamb": (83, 65, 310),
            "steak": (77, 56, 323),
            "ground beef": (78, 76, 305),
            "duck": (84, 59, 271),
            "chicken breast": (85, 65, 256),
            "chicken wings": (93, 86, 243),
            
            // Seafood
            "salmon": (55, 59, 363),
            "tuna": (38, 37, 237),
            "shrimp": (189, 111, 220),
            "crab": (78, 320, 275),
            "lobster": (95, 323, 300),
            "cod": (43, 58, 302),
            "tilapia": (57, 56, 302),
            "trout": (63, 58, 375),
            "halibut": (41, 59, 490),
            
            // Dairy
            "milk": (10, 43, 150),
            "cheese": (105, 653, 98),
            "yogurt": (12, 56, 234),
            "butter": (215, 714, 24),
            "cream": (166, 104, 28),
            
            // Grains
            "rice": (0, 5, 55),
            "bread": (0, 450, 107),
            "pasta": (0, 1, 61),
            "oat": (0, 2, 165),
            "quinoa": (0, 7, 172),
            
            // Others
            "egg": (373, 124, 126),
            "honey": (0, 4, 52),
            "olive oil": (0, 2, 1),
            "peanut butter": (0, 156, 208)
        ]
        
        // Check for exact match first
        if let exact = additionalNutrition[name] {
            return exact
        }
        
        // Check for partial match
        for (key, value) in additionalNutrition {
            if name.contains(key) || key.contains(name) {
                return value
            }
        }
        
        // Standard values if no match found
        return (20, 80, 200)
    }
    
    // Helper function to get food category
    private static func getFoodCategory(for name: String) -> String {
        let vegetables = ["tomato", "broccoli", "carrot", "spinach", "kale", "potato", "garlic", 
                         "bell pepper", "corn", "endive", "lettuce", "celery", "onion", "green bean",
                         "asparagus", "cabbage", "cucumber", "eggplant", "zucchini", "squash", "pumpkin"]
        
        let fruits = ["apple", "banana", "orange", "pineapple", "grape", "strawberry", 
                      "blueberry", "avocado", "coconut", "mango", "watermelon", "kiwi", "peach",
                      "pear", "plum", "cherry", "lemon", "lime", "grapefruit", "raspberry", "blackberry"]
        
        let meats = ["chicken", "beef", "pork", "bacon", "ham", "turkey", "sausage", "lamb",
                    "steak", "ground beef", "brisket", "ribs", "veal", "venison", "duck"]
        
        let seafood = ["salmon", "tuna", "shrimp", "crab", "lobster", "cod", "tilapia",
                       "trout", "halibut", "sardine", "anchovy", "mackerel", "oyster", "clam", "mussel", "scallop"]
                       
        let grains = ["rice", "bread", "pasta", "oat", "barley", "quinoa", "couscous", "cereal",
                     "wheat", "bulgur", "rye", "buckwheat", "millet", "corn", "tortilla"]
                     
        let dairy = ["milk", "cheese", "yogurt", "butter", "cream", "ice cream", "cottage cheese",
                    "sour cream", "cream cheese", "cheddar", "mozzarella", "parmesan", "brie"]
                    
        let spices = ["salt", "pepper", "oregano", "basil", "thyme", "rosemary", "cinnamon",
                     "cumin", "curry", "paprika", "chili", "nutmeg", "ginger", "turmeric", "cardamom"]
                     
        let condiments = ["ketchup", "mustard", "mayonnaise", "sauce", "dressing", "vinegar",
                         "oil", "honey", "syrup", "jam", "jelly", "salsa", "relish", "soy sauce"]
        
        // Check for matches in each category
        if containsAny(name, words: vegetables) { return "Vegetables" }
        if containsAny(name, words: fruits) { return "Fruits" }
        if containsAny(name, words: meats) { return "Meats" }
        if containsAny(name, words: seafood) { return "Seafood" }
        if containsAny(name, words: grains) { return "Grains" }
        if containsAny(name, words: dairy) { return "Dairy" }
        if containsAny(name, words: spices) { return "Spices" }
        if containsAny(name, words: condiments) { return "Condiments" }
        
        return "Other"
    }
    
    // Helper function to check if a string contains any word from a list
    private static func containsAny(_ text: String, words: [String]) -> Bool {
        for word in words {
            if text.contains(word) || word.contains(text) {
                return true
            }
        }
        return false
    }
}
