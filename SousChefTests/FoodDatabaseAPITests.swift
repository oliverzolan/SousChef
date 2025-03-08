import XCTest
@testable import SousChef

class FoodDatabaseAPITests: XCTestCase {

    var foodDatabaseAPI: FoodDatabaseAPI!

    override func setUp() {
        super.setUp()
        foodDatabaseAPI = FoodDatabaseAPI()
    }

    override func tearDown() {
        foodDatabaseAPI = nil
        super.tearDown()
    }

    func testSearchFoodsSuccess() {
        let expectation = self.expectation(description: "API should return food search results")

        foodDatabaseAPI.searchFoods(query: "Apple") { result in
            switch result {
            case .success(let foods):
                XCTAssertFalse(foods.isEmpty, "Food results should not be empty")
                XCTAssertEqual(foods.first?.label, "Apple", "First result should be Apple")
            case .failure(let error):
                XCTFail("API call failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testSearchFoodsFailure() {
        let expectation = self.expectation(description: "API should handle failure case")
        
        let mockAPI = MockFoodDatabaseAPI()
        mockAPI.shouldReturnSuccess = false
        
        mockAPI.searchFoods(query: "INVALID_QUERY_HEHE") { result in
            switch result {
            case .success:
                XCTFail("API should fail but returned success")
            case .failure(let error):
                XCTAssertNotNil(error, "Error should be returned for invalid query")
                XCTAssertEqual((error as NSError).domain, "MockAPI", "Expected MockAPI failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
}

