import Foundation

class IngredientMatchingService {
    static let shared = IngredientMatchingService()
    
    private var knownIngredients: [String] = []
    private var edamamAPI: EdamamIngredientsComponent
    
    private init() {
        // Initialize with default appId and appKey
        self.edamamAPI = EdamamIngredientsComponent()
        loadKnownIngredients()
    }
    
    private func loadKnownIngredients() {
        // Try different path patterns to find the ingredients.json file
        let possiblePaths = [
            Bundle.main.path(forResource: "ingredients", ofType: "json", inDirectory: "Backend/Components/ReceiptScanner"),
            Bundle.main.path(forResource: "ingredients", ofType: "json"),
            Bundle.main.path(forResource: "ingredients", ofType: "json", inDirectory: "ReceiptScanner")
        ]
        
        for path in possiblePaths.compactMap({ $0 }) {
            do {
                // Fixed: Use a do-catch block for proper error handling
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                do {
                    knownIngredients = try JSONDecoder().decode([String].self, from: data)
                    print("Loaded \(knownIngredients.count) known ingredients from \(path)")
                    return
                } catch {
                    print("Error decoding ingredients.json at \(path): \(error)")
                }
            } catch {
                print("Error reading file at \(path): \(error)")
            }
        }
        
        // Try to load from the hardcoded JSON string
        if let data = hardcodedIngredientsJSON.data(using: .utf8) {
            do {
                knownIngredients = try JSONDecoder().decode([String].self, from: data)
                print("Loaded \(knownIngredients.count) ingredients from hardcoded JSON")
                return
            } catch {
                print("Error decoding hardcoded ingredients JSON: \(error)")
            }
        }
        
        // If we get here, we couldn't load from any source, so use fallback
        print("Could not load ingredients from any source, using fallback list")
        knownIngredients = getBasicIngredientsList()
    }
    
    func matchIngredients(_ recognizedItems: [String], completion: @escaping (Result<[RecognizedIngredientWithDetails], Error>) -> Void) {
        // 1. Process recognized items to match with known ingredients
        let processedItems = preprocessRecognizedItems(recognizedItems)
        
        // 2. Match with our known ingredients
        let matches = findMatches(for: processedItems)
        
        // 3. For each match, search in Edamam API
        let dispatchGroup = DispatchGroup()
        var enrichedIngredients: [RecognizedIngredientWithDetails] = []
        var errors: [Error] = []
        
        for match in matches {
            dispatchGroup.enter()
            
            searchEdamamForIngredient(match) { result in
                switch result {
                case .success(let details):
                    DispatchQueue.main.async {
                        enrichedIngredients.append(details)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        errors.append(error)
                        // Still add the ingredient with basic info since we recognized it
                        enrichedIngredients.append(
                            RecognizedIngredientWithDetails(
                                name: match,
                                edamamFoodId: UUID().uuidString,
                                category: "Generic",
                                imageURL: "",
                                quantityType: "Serving",
                                expirationDays: 7
                            )
                        )
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !errors.isEmpty {
                print("Encountered \(errors.count) errors while enriching ingredients")
            }
            
            // Sort by name for consistency
            let sortedResult = enrichedIngredients.sorted { $0.name < $1.name }
            completion(.success(sortedResult))
        }
    }
    
    private func preprocessRecognizedItems(_ items: [String]) -> [String] {
        // Clean up and normalize the recognized items
        return items.map { item in
            // Convert to lowercase, trim whitespace
            var normalized = item.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove common prefixes/suffixes like "fresh", "frozen", etc.
            let prefixesToRemove = ["fresh ", "frozen ", "raw ", "cooked ", "sliced ", "diced ", "chopped ", "minced ", "whole ", "organic "]
            for prefix in prefixesToRemove {
                if normalized.hasPrefix(prefix) {
                    normalized = String(normalized.dropFirst(prefix.count))
                }
            }
            
            return normalized
        }
    }
    
    private func findMatches(for items: [String]) -> [String] {
        var matches: [String] = []
        
        for item in items {
            // Try exact match first
            if knownIngredients.contains(item) {
                matches.append(item)
                continue
            }
            
            // Try prefix matching (e.g. "tomato" matches "tomatoes")
            if let match = findBestPrefixMatch(for: item) {
                matches.append(match)
                continue
            }
            
            // If no match found, still include the item for fallback processing
            matches.append(item)
        }
        
        return matches
    }
    
    private func findBestPrefixMatch(for item: String) -> String? {
        // Find known ingredients that have this item as a prefix, or vice versa
        let itemSingular = item.hasSuffix("s") ? String(item.dropLast()) : item
        let itemPlural = item.hasSuffix("s") ? item : item + "s"
        
        // Check if a known ingredient is a prefix of our item
        for knownItem in knownIngredients {
            if item.hasPrefix(knownItem) || itemSingular.hasPrefix(knownItem) {
                return knownItem
            }
            
            // Check if our item is a prefix of a known ingredient
            if knownItem.hasPrefix(item) || knownItem.hasPrefix(itemSingular) {
                return knownItem
            }
            
            // Check for plural/singular form
            if knownItem.hasSuffix("s") && String(knownItem.dropLast()) == itemSingular {
                return knownItem
            }
            
            if itemPlural == knownItem {
                return knownItem
            }
        }
        
        return nil
    }
    
    private func searchEdamamForIngredient(_ ingredient: String, completion: @escaping (Result<RecognizedIngredientWithDetails, Error>) -> Void) {
        edamamAPI.searchIngredients(query: ingredient) { result in
            switch result {
            case .success(let response):
                if let firstHint = response.hints.first {
                    // Fixed: Access correct property names from EdamamIngredientModel
                    let food = firstHint.food
                    let category = food.categoryLabel ?? food.category ?? "Generic"
                    let imageURL = food.image ?? ""
                    
                    let details = RecognizedIngredientWithDetails(
                        name: ingredient,
                        edamamFoodId: food.foodId,
                        category: category,
                        imageURL: imageURL,
                        quantityType: "Serving",
                        expirationDays: 7
                    )
                    
                    completion(.success(details))
                } else {
                    // No matching food found in Edamam, create a generic one
                    let details = RecognizedIngredientWithDetails(
                        name: ingredient,
                        edamamFoodId: UUID().uuidString,
                        category: "Generic",
                        imageURL: "",
                        quantityType: "Serving",
                        expirationDays: 7
                    )
                    
                    completion(.success(details))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fallback ingredients list if we can't load from JSON
    private func getBasicIngredientsList() -> [String] {
        return [
            "apple", "banana", "carrot", "onion", "garlic", "potato", "tomato", "chicken", "beef", "pork",
            "fish", "rice", "pasta", "cheese", "milk", "butter", "salt", "sugar", "flour", "egg",
            "pepper", "olive oil", "lemon", "lime", "bread", "spinach", "broccoli", "cucumber", "lettuce",
            "mushroom", "corn", "peanut butter", "honey", "chocolate", "cream", "yogurt", "beans",
            "peas", "lentils", "avocado", "chili", "soy sauce", "vinegar", "basil", "parsley", "cilantro",
            "mint", "rosemary", "thyme", "oregano", "paprika", "cinnamon", "cumin", "turmeric",
            "ginger", "watermelon", "strawberry", "blueberry", "raspberry", "orange", "peach"
        ]
    }
    
    // Hardcoded ingredients JSON as a fallback
    private let hardcodedIngredientsJSON = """
    [
      "apple",
      "banana",
      "orange",
      "strawberry",
      "blueberry",
      "raspberry",
      "blackberry",
      "grape",
      "watermelon",
      "cantaloupe",
      "pineapple",
      "mango",
      "peach",
      "pear",
      "plum",
      "kiwi",
      "lemon",
      "lime",
      "avocado",
      "coconut",
      "date",
      "carrot",
      "broccoli",
      "spinach",
      "lettuce",
      "kale",
      "cabbage",
      "cauliflower",
      "cucumber",
      "tomato",
      "bell pepper",
      "onion",
      "garlic",
      "potato",
      "sweet potato",
      "zucchini",
      "eggplant",
      "asparagus",
      "celery",
      "mushroom",
      "corn",
      "green bean",
      "pea",
      "brussels sprout",
      "artichoke",
      "radish",
      "beet",
      "turnip",
      "leek",
      "shallot",
      "scallion",
      "bok choy",
      "arugula",
      "watercress",
      "okra",
      "parsnip",
      "rutabaga",
      "fennel",
      "endive",
      "radicchio",
      "collard greens",
      "swiss chard",
      "pumpkin",
      "butternut squash",
      "acorn squash",
      "spaghetti squash",
      "jicama",
      "tomatillo",
      "chayote",
      "kohlrabi",
      "daikon",
      "milk",
      "butter",
      "cheese",
      "yogurt",
      "cream",
      "sour cream",
      "cream cheese",
      "cottage cheese",
      "ricotta cheese",
      "mozzarella cheese",
      "cheddar cheese",
      "swiss cheese",
      "parmesan cheese",
      "gouda cheese",
      "brie cheese",
      "blue cheese",
      "feta cheese",
      "goat cheese",
      "provolone cheese",
      "american cheese"
    ]
    """
} 