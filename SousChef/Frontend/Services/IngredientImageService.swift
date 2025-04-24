import Foundation
import SwiftUI

/// Service to handle and provide consistent ingredient image URLs
class IngredientImageService {
    static let shared = IngredientImageService()
    
    // CloudFront URL for ingredient images
    private let baseImageURL = "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/"
    
    // Old S3 URL for migration purposes
    private let oldBaseImageURL = "https://ingredient-images.s3.us-east-1.amazonaws.com/ingredients/"
    
    // Category mapping to ensure consistent folder names
    private let categoryMapping: [String: String] = [
        "vegetable": "vegetables",
        "vegetables": "vegetables",
        "fruit": "Fruits",
        "fruits": "Fruits",
        "meat": "meats",
        "protein": "meats",
        "dairy": "dairy",
        "grain": "grains",
        "grains": "grains",
        "canned": "canned_goods",
        "canned goods": "canned_goods",
        "canned_goods": "canned_goods",
        "spice": "spices",
        "spices": "spices",
        "condiment": "condiments",
        "condiments": "condiments",
        "drink": "beverage",
        "drinks": "beverage",
        "beverage": "beverage",
        "beverages": "beverage"
    ]
    
    // Special case ingredients that have custom image names
    private let specialCaseIngredients: [String: String] = [
        "beef": "beef_steak",
        "cheddar cheese": "cheddar_cheese",
        "greek yogurt": "greek_yogurt",
        "garlic powder": "garlic_powder",
        "canned beans": "beans",
        "canned tomatoes": "tomatoes",
        "canned tuna": "tuna",
        "canned corn": "corn",
        "canned soup": "soup"
    ]
    
    private init() {
        // Private initializer for singleton
    }
    
    func getImageURL(for name: String, category: String, existingURL: String? = nil) -> String {
        // Check if existingURL is using the old S3 pattern and convert it to the new CloudFront URL
        if let url = existingURL, !url.isEmpty {
            if url.contains("amazonaws.com") {
                // Convert from old S3 URL to new CloudFront URL
                if let path = extractPathFromOldURL(url) {
                    return migrateToCloudFrontURL(path: path, name: name, category: category)
                }
            } else if URL(string: url) != nil {
                // It's a valid URL that's not from the old S3 bucket, use it
                return url
            }
        }
        
        let lowercaseName = name.lowercased()
        let lowercaseCategory = category.lowercased()
        
        // Get the proper category folder
        let categoryFolder = categoryMapping[lowercaseCategory] ?? lowercaseCategory
        
        // Check for special case ingredients
        let imageName: String
        if let specialCase = specialCaseIngredients[lowercaseName] {
            imageName = specialCase
        } else {
            // Convert spaces to underscores for the filename
            imageName = lowercaseName.replacingOccurrences(of: " ", with: "_")
        }
        
        // Use webp for all images
        let fileExtension = ".webp"
        
        // Build the URL path: categoryFolder/ingredient_name.webp
        let url = baseImageURL + categoryFolder + "/" + imageName + fileExtension
        return url
    }
    
    // Extract the path (category/ingredient_name) from an old S3 URL
    private func extractPathFromOldURL(_ url: String) -> String? {
        if let range = url.range(of: oldBaseImageURL) {
            // Extract everything after the oldBaseImageURL
            let path = url[range.upperBound...]
            // Remove file extension if present
            let pathWithoutExtension = path.replacingOccurrences(of: ".png", with: "")
                                           .replacingOccurrences(of: ".webp", with: "")
            return String(pathWithoutExtension)
        }
        return nil
    }
    
    // Create a new CloudFront URL from an extracted path
    private func migrateToCloudFrontURL(path: String, name: String, category: String) -> String {
        // Split the path to get the category and ingredient
        let components = path.split(separator: "/")
        
        if components.count >= 2 {
            let oldCategory = String(components[0])
            
            // Map old category to new format
            let newCategory: String
            if oldCategory.lowercased() == "fruits" {
                newCategory = "Fruits"
            } else if oldCategory.lowercased() == "canned" {
                newCategory = "canned_goods"
            } else {
                newCategory = oldCategory
            }
            
            // Combine with .webp extension
            let url = baseImageURL + newCategory + "/" + components[1...].joined(separator: "/") + ".webp"
            return url
        } else {
            // If we can't extract components properly, generate a new URL
            return getImageURL(for: name, category: category)
        }
    }
    
    func createIngredient(
        name: String,
        category: String,
        edamamFoodId: String? = nil,
        quantityType: String = "Serving",
        expirationDuration: Int = 7
    ) -> AWSIngredientModel {
        let imageURL = getImageURL(for: name, category: category)
        
        return AWSIngredientModel(
            edamamFoodId: edamamFoodId ?? UUID().uuidString,
            foodCategory: category,
            name: name,
            quantityType: quantityType,
            experiationDuration: expirationDuration,
            imageURL: imageURL
        )
    }
} 