//
//  FatSecretAPI.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import UIKit

class FatSecretAPI {
    static let shared = FatSecretAPI()

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func encodeImageToBase64(image: UIImage) -> String? {
        // Resize image to 512x512 to reduce size
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 512, height: 512)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else { return nil }
        
        return imageData.base64EncodedString()
    }

    func recognizeFood(image: UIImage, token: String, completion: @escaping ([FoodScannerFood]?) -> Void) {
        guard let base64Image = encodeImageToBase64(image: image) else {
            print("Failed to encode image")
            completion(nil)
            return
        }

        let url = URL(string: "https://platform.fatsecret.com/rest/image-recognition/v1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "image_b64": base64Image,
            "region": "US",
            "language": "en",
            "include_food_data": true
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in FatSecret API call: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: No valid HTTP response")
                completion(nil)
                return
            }

            if let rawResponse = String(data: data ?? Data(), encoding: .utf8) {
                print("Raw FatSecret Response (Status \(httpResponse.statusCode)): \(rawResponse)")
            }

            guard let data = data, httpResponse.statusCode == 200 else {
                print("Error: Non-200 status code received (\(httpResponse.statusCode))")
                completion(nil)
                return
            }

            do {
                let foodResponse = try JSONDecoder().decode(FoodScannerResponse.self, from: data)
                completion(foodResponse.food_response)
            } catch {
                print("Failed to decode FatSecret response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
