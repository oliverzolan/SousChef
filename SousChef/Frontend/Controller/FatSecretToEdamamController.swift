//
//  FatSecretToEdamamController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import Foundation
import UIKit

class FatSecretToEdamamController {
    static let shared = FatSecretToEdamamController()

    private let edamamAPI = EdamamIngredientsComponent()

    func recognizeAndMatchFood(image: UIImage, completion: @escaping ([EdamamIngredientModel]) -> Void) {
        FatSecretAuth.shared.fetchAccessToken { token in
            guard let token = token else {
                print("Error: Failed to fetch FatSecret token.")
                completion([])
                return
            }
            
            FatSecretAPI.shared.recognizeFood(image: image, token: token) { fatSecretFoods in
                guard let fatSecretFoods = fatSecretFoods, !fatSecretFoods.isEmpty else {
                    print("Error: FatSecret did not return any recognized foods.")
                    completion([])
                    return
                }

                var matchedFoods: [EdamamIngredientModel] = []
                let dispatchGroup = DispatchGroup()

                for fatSecretFood in fatSecretFoods {
                    dispatchGroup.enter()
                    
                    let fatSecretFoodName = fatSecretFood.food_entry_name
                    
                    print("Searching for Edamam match: \(fatSecretFoodName)")
                    
                    self.edamamAPI.searchIngredients(query: fatSecretFoodName) { result in
                        switch result {
                        case .success(let edamamResponse):
                            if let bestMatch = self.findBestEdamamMatch(edamamResponse: edamamResponse, fatSecretFoodName: fatSecretFoodName) {
                                matchedFoods.append(bestMatch)
                            } else {
                                print("No match found for: \(fatSecretFoodName)")
                            }
                        case .failure(let error):
                            print("Error searching Edamam: \(error.localizedDescription)")
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("Matching complete. Found \(matchedFoods.count) Edamam matches.")
                    completion(matchedFoods)
                }
            }
        }
    }

    private func findBestEdamamMatch(edamamResponse: EdamamIngredientResponse, fatSecretFoodName: String) -> EdamamIngredientModel? {
        let normalizedFatSecretName = fatSecretFoodName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        for hint in edamamResponse.hints {
            let edamamLabel = hint.food.label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if normalizedFatSecretName.contains(edamamLabel) || edamamLabel.contains(normalizedFatSecretName) {
                return hint.food
            }
        }

        return nil
    }
}
