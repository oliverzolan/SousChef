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
    
    private var userSession: UserSession
    private var ingredientsComponent: AWSIngredientsComponent

    init(userSession: UserSession) {
        self.userSession = userSession
        self.ingredientsComponent = AWSIngredientsComponent(userSession: userSession)
    }

    func fetchIngredients() {
        guard userSession.token != nil else {
            self.errorMessage = "User is not authenticated."
            return
        }

        isLoading = true
        errorMessage = nil

        ingredientsComponent.fetchIngredients { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let ingredients):
                    let oldCount = self?.pantryItems.count ?? 0
                    self?.pantryItems = ingredients
                    // Call the callback if items changed
                    if oldCount != ingredients.count {
                        self?.onPantryItemsChanged?()
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch ingredients: \(error.localizedDescription)"
                }
            }
        }
    }
}
