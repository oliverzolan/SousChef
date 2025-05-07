import Foundation
import UIKit

class VisionAPIService {
    static let shared = VisionAPIService()
    
    private init() {}
    
    private func getApiKey() -> String? {
        return EnvFileManager.shared.getValue(forKey: "OPENAI_API_KEY")
    }
    
    func recognizeIngredientsInImage(_ image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let apiKey = getApiKey() else {
            completion(.failure(NSError(domain: "VisionAPIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key not found"])))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "VisionAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Construct the request payload with an improved prompt
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a helpful assistant specialized in recognizing food ingredients from images with high accuracy.
                    
                    RULES:
                    1. List all visible food ingredients, one per line
                    2. Use simple, standard ingredient names (e.g., "tomatoes" instead of "roma tomatoes")
                    3. Be specific but not overly detailed (e.g., "chicken breast" is good, but just "chicken" is acceptable too)
                    4. Ignore packaging, utensils, or non-food items
                    5. DO NOT include explanations, descriptions, or categorizations
                    6. DO NOT include cooking methods or preparations (e.g., "diced", "sliced")
                    7. DO NOT make up ingredients if you're not certain
                    8. If multiple similar items are present (e.g., different types of peppers), list the general category
                    9. Use common ingredient names that would be found in a typical pantry or grocery store inventory
                    """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "What food ingredients do you see in this image? Please list only the ingredients, one per line."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        // Create the request
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "VisionAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "VisionAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                // Parse the response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Process the response into a list of ingredients
                    let ingredients = content
                        .components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .filter { !$0.hasPrefix("-") }
                        .map { 
                            // Remove any numbered prefixes (e.g., "1. Tomato" -> "Tomato")
                            let parts = $0.components(separatedBy: ". ")
                            if parts.count > 1, let _ = Int(parts[0]) {
                                return parts[1...].joined(separator: ". ")
                            }
                            return $0
                        }
                    
                    DispatchQueue.main.async {
                        completion(.success(ingredients))
                    }
                } else {
                    DispatchQueue.main.async {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Error parsing JSON response: \(jsonString)")
                        }
                        completion(.failure(NSError(domain: "VisionAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
} 