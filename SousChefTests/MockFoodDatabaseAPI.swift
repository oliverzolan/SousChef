import XCTest
@testable import SousChef

class MockFoodDatabaseAPI: FoodDatabaseAPI {
    var shouldReturnSuccess = true
    
    override func searchFoods(query: String, completion: @escaping (Result<[FoodModel], Error>) -> Void) {
        if shouldReturnSuccess {
            let mockData = [
                FoodModel(
                    foodId: "123",
                    label: "Apple",
                    category: "Fruits",
                    categoryLabel: "Fruit",
                    image: nil,
                    nutrients: FoodNutrients(ENERC_KCAL: nil, PROCNT: nil, FAT: nil, CHOCDF: nil, FIBTG: nil)
                )
            ]
            completion(.success(mockData))
        } else {
            completion(.failure(NSError(domain: "MockAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mocked API Failure"])))
        }
    }
}
