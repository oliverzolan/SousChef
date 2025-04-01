//
//  BarcodeAPIComponent.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/7/25.
//

import Foundation

// Handles barcode-based food lookups using Edamam API.
final class BarcodeAPIComponent {
    
    private let baseURL = "https://api.edamam.com"
    private let apiEndpoint = "/api/food-database/v2/parser"
    private let appId: String
    private let appKey: String
    
    init(appId: String = "d76328ea", appKey: String = "011912e96073eeb8e2088ecb41b78676") {
        self.appId = appId
        self.appKey = appKey
    }
        
    // Fetches food details by scanning a barcode (UPC).
    func fetchFoodByBarcode(upc: String, completion: @escaping (Result<BarcodeModel?, Error>) -> Void) {
        guard let encodedUPC = upc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(BarcodeAPIError.invalidUPC))
            return
        }
        
        let urlString = "\(baseURL)\(apiEndpoint)?app_id=\(appId)&app_key=\(appKey)&upc=\(encodedUPC)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(BarcodeAPIError.invalidURL))
            return
        }

        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(BarcodeAPIError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(EdamamBarcodeResponse.self, from: data)
                
                if let firstFood = decodedResponse.hints.first?.food {
                    let scannedItem = BarcodeModel(
                        foodId: firstFood.foodId,
                        label: firstFood.label,
                        brand: firstFood.brand,
                        category: firstFood.category,
                        image: firstFood.image,
                        nutrients: firstFood.nutrients
                    )

                    completion(.success(scannedItem))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(BarcodeAPIError.decodingError(error)))
            }
        }.resume()
    }
}

// Error handling
enum BarcodeAPIError: Error, LocalizedError {
    case invalidUPC
    case invalidURL
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUPC:
            return "The scanned barcode is invalid or improperly formatted."
        case .invalidURL:
            return "The API request URL is invalid."
        case .noData:
            return "No data was returned from the API."
        case .decodingError(let error):
            return "Failed to decode API response: \(error.localizedDescription)"
        }
    }
}
