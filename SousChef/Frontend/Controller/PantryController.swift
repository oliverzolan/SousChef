//
//  pantryController.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/5/25.
//


import Foundation
import FirebaseAuth

class PantryController: ObservableObject {
    @Published var pantryItems: [AWSIngredientModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Callback for when pantry items change, to notify HomepageController
    var onPantryItemsChanged: (() -> Void)?
    
    // Made public so it can be updated from outside
    var userSession: UserSession {
        didSet {
            // Update dependencies when userSession changes
            userIngredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
            internalIngredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
        }
    }
    private var userIngredientsComponent: AWSUserIngredientsComponent
    private var internalIngredientsComponent: AWSUserIngredientsComponent

    init(userSession: UserSession) {
        self.userSession = userSession
        self.userIngredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
        self.internalIngredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
    }

    func fetchIngredients() {
        guard userSession.token != nil else {
            self.errorMessage = "User is not authenticated."
            return
        }

        isLoading = true
        errorMessage = nil

        userIngredientsComponent.fetchIngredients { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let ingredients):
                    // Store the ingredients, even if empty
                    self?.pantryItems = ingredients
                    
                    // Provide visual indicator when pantry is empty
                    if ingredients.isEmpty {
                        // Use mock data if enabled
                        if MockDataConfig.shouldUseMockData {
                            self?.pantryItems = self?.createMockIngredients() ?? []
                        }
                    }
                    
                case .failure(let error):
                    // Don't change pantryItems on error, keep existing data
                    self?.errorMessage = "Failed to fetch ingredients: \(error.localizedDescription)"
                    
                    // Use mock data if enabled
                    if MockDataConfig.shouldUseMockData {
                        self?.pantryItems = self?.createMockIngredients() ?? []
                    }
                }
            }
        }
    }
    
    // Create mock ingredients for testing when backend is unavailable
    private func createMockIngredients() -> [AWSIngredientModel] {
        return [
            // Meats
            AWSIngredientModel(
                edamamFoodId: "mock_chicken",
                foodCategory: "Meat",
                name: "Chicken",
                quantityType: "2",
                experiationDuration: 3,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/meats/chicken.webp"
            ),
            AWSIngredientModel(
                edamamFoodId: "mock_beef",
                foodCategory: "Meat",
                name: "Beef",
                quantityType: "1",
                experiationDuration: 5,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/meats/beef_steak.webp"
            ),
            
            // Fruits
            AWSIngredientModel(
                edamamFoodId: "mock_apple",
                foodCategory: "Fruit",
                name: "Apple",
                quantityType: "5",
                experiationDuration: 7,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/Fruits/apple.webp"
            ),
            AWSIngredientModel(
                edamamFoodId: "mock_banana",
                foodCategory: "Fruit",
                name: "Banana",
                quantityType: "4",
                experiationDuration: 5,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/Fruits/banana.webp"
            ),
            
            // Vegetables
            AWSIngredientModel(
                edamamFoodId: "mock_carrot",
                foodCategory: "Vegetable",
                name: "Carrot",
                quantityType: "3",
                experiationDuration: 14,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/vegetables/carrot.webp"
            ),
            AWSIngredientModel(
                edamamFoodId: "mock_broccoli",
                foodCategory: "Vegetable",
                name: "Broccoli",
                quantityType: "2",
                experiationDuration: 5,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/vegetables/broccoli.webp"
            ),
            
            // Condiments
            AWSIngredientModel(
                edamamFoodId: "mock_ketchup",
                foodCategory: "Condiment",
                name: "Ketchup",
                quantityType: "1",
                experiationDuration: 180,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/condiments/ketchup.webp"
            ),
            
            // Spices
            AWSIngredientModel(
                edamamFoodId: "mock_pepper",
                foodCategory: "Spice",
                name: "Pepper",
                quantityType: "1",
                experiationDuration: 365,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/spices/pepper.webp"
            ),
            
            // Canned Goods
            AWSIngredientModel(
                edamamFoodId: "mock_canned_beans",
                foodCategory: "Canned Goods",
                name: "Canned Beans",
                quantityType: "1",
                experiationDuration: 365,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/canned_goods/beans.webp"
            ),
            
            // Beverages
            AWSIngredientModel(
                edamamFoodId: "mock_orange_juice",
                foodCategory: "Beverage",
                name: "Orange Juice",
                quantityType: "1",
                experiationDuration: 7,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/beverage/orange_juice.webp"
            )
        ]
    }
}
