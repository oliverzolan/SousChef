import Foundation

class NutritionController: ObservableObject {
    @Published var isLoading: Bool = false
    
    private let awsInternalIngredientsComponent: AWSInternalIngredientsComponent
    
    init(userSession: UserSession) {
        self.awsInternalIngredientsComponent = AWSInternalIngredientsComponent(userSession: userSession)
    }
    
    @MainActor
    func fetchIngredientNutrition(for id: String, completion: @escaping (Result<AWSIngredientNutritionModel, Error>) -> Void) {
        isLoading = true
        
        awsInternalIngredientsComponent.getIngredientNutrtion(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let responseData):
                    do {
                        if let rawJsonString = responseData.first as? String,
                           let jsonData = rawJsonString.data(using: .utf8) {
                            
                            print("Decoding from raw JSON string: \(rawJsonString)")
                            let nutrition = try JSONDecoder().decode(AWSIngredientNutritionModel.self, from: jsonData)
                            completion(.success(nutrition))
                            return
                        }
                        
                        if let nutritionDict = responseData.first as? [String: Any] {
                            let jsonData = try JSONSerialization.data(withJSONObject: nutritionDict)
                            let nutrition = try JSONDecoder().decode(AWSIngredientNutritionModel.self, from: jsonData)
                            completion(.success(nutrition))
                            return
                        }
                        
                        // If we can't process the response, throw an error
                        throw NSError(domain: "", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Could not process nutrition data. Raw response: \(responseData)"
                        ])
                        
                    } catch {
                        print("Nutrition decoding error: \(error)")
                        print("Raw response data: \(responseData)")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
