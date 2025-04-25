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

    @MainActor func fetchIngredients() {
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
                    
                case .failure(let error):
                    // Don't change pantryItems on error, keep existing data
                    self?.errorMessage = "Failed to fetch ingredients: \(error.localizedDescription)"
                }
            }
        }
    }
}
