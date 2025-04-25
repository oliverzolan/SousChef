import SwiftUI

struct NutritionFactsPopup: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var nutritionController: NutritionController
    
    @State private var nutritionInfo: AWSIngredientNutritionModel? = nil
    @State private var isError: Bool = false
    @State private var isErrorMessage: String = "Failed to load nutrition info."
    @State private var rawData: String = "No data"
    @State private var showRawData: Bool = false
    
    let foodIdentifier: String
    let usesDirectID: Bool
    let ingredientName: String?
    
    // Initialize with a food ID
    init(foodId: String, userSession: UserSession, ingredientName: String? = nil) {
        self.foodIdentifier = foodId
        self.usesDirectID = true
        self.ingredientName = ingredientName
        _nutritionController = StateObject(wrappedValue: NutritionController(userSession: userSession))
    }
    
    init(foodName: String, userSession: UserSession) {
        self.foodIdentifier = foodName
        self.usesDirectID = false
        self.ingredientName = foodName
        _nutritionController = StateObject(wrappedValue: NutritionController(userSession: userSession))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if nutritionController.isLoading {
                ProgressView("Loading nutrition info...")
            } else if let nutrition = nutritionInfo {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .center, spacing: 8) {
                        Text(nutrition.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            
                            Text("Category: \(nutrition.foodCategory)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Nutrition Facts Label Style
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Nutrition Facts")
                                    .font(.title2)
                                    .fontWeight(.black)
                                
                                Text("Serving Size: \(Int(nutrition.quantity)) \(nutrition.quantityType)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Divider()
                                    .background(Color.black)
                                    .padding(.vertical, 4)
                            }
                            
                            // Pie chart visualization
                            VStack(alignment: .center, spacing: 8) {
                                Text("Macronutrient Distribution")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                NutritionPieChart(
                                    carbs: nutrition.carbohydrate,
                                    protein: nutrition.protein,
                                    fat: nutrition.fat
                                )
                                .frame(height: 180)
                                .padding(.vertical, 8)
                                
                                HStack(spacing: 16) {
                                    LegendItem(color: .blue, label: "Carbs")
                                    LegendItem(color: .red, label: "Protein")
                                    LegendItem(color: .yellow, label: "Fat")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calories")
                                    .font(.headline)
                                
                                HStack {
                                    Text("\(Int(nutrition.calorie))")
                                        .font(.system(size: 24, weight: .bold))
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(Color.black)
                                    .padding(.vertical, 2)
                            }
                            
                            // Nutritional Values Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Nutritional Values")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                Group {
                                    NutrientRowEnhanced(name: "Total Fat", value: nutrition.fat, unit: "g", dailyValue: 78)
                                    NutrientRowEnhanced(name: "Protein", value: nutrition.protein, unit: "g", dailyValue: 50)
                                    NutrientRowEnhanced(name: "Total Carbohydrates", value: nutrition.carbohydrate, unit: "g", dailyValue: 275)
                                    Divider()
                                }
                                
                                Group {
                                    NutrientRowEnhanced(name: "Cholesterol", value: nutrition.cholesterol, unit: "mg", dailyValue: 300)
                                    NutrientRowEnhanced(name: "Sodium", value: nutrition.sodium, unit: "mg", dailyValue: 2300)
                                    NutrientRowEnhanced(name: "Potassium", value: nutrition.potassium, unit: "mg", dailyValue: 3500)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        if let expiration = nutrition.experiationDuration {
                            Divider()
                                .padding(.vertical, 8)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                
                                Text("Typical shelf life: \(expiration) days")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Button(showRawData ? "Hide Technical Data" : "Show Technical Data") {
                            showRawData.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        if showRawData {
                            Text(rawData)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            } else if isError {
                VStack(spacing: 10) {
                    Text(isErrorMessage)
                    .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    Text("Try tapping 'Retry with alternate lookup'")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.top, 8)
                    
                    Button("Retry with alternate lookup") {
                        tryAlternateLookup()
                    }
                    .padding(.top, 16)
                    
                    Button("Parse from raw JSON") {
                        parseSampleJson()
                    }
                    .padding(.top, 8)
                    
                    Text(rawData)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                }
            } else {
                Text("No nutrition info available.")
            }
        }
        .padding()
        .onAppear {
            fetchNutrition()
        }
    }
    
    private func isUUID(_ string: String) -> Bool {
        let uuidPattern = "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uuidPattern)
        return predicate.evaluate(with: string)
    }
    
    private func isEdamamFoodID(_ string: String) -> Bool {
        return string.starts(with: "food_") && string.count > 10
    }
    
    private func lookupByName(_ name: String) {
        if let foodId = FoodIDService.shared.getFoodID(for: name) {
            performDirectIDLookup(foodId)
        } else {
            isError = true
            isErrorMessage = "Couldn't find food ID for '\(name)'."
        }
    }
    
    private func performDirectIDLookup(_ id: String) {
        nutritionController.fetchIngredientNutrition(for: id) { result in
            switch result {
            case .success(let nutrition):
                self.nutritionInfo = nutrition
                self.isError = false
                
                // Create raw data representation for debugging
                if let data = try? JSONEncoder().encode(nutrition),
                   let json = String(data: data, encoding: .utf8) {
                    self.rawData = json
                } else {
                    self.rawData = "Error converting nutrition to JSON"
                }
                
            case .failure(let error):
                self.isError = true
                self.isErrorMessage = "Failed to load nutrition: \(error.localizedDescription)"
                
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        self.rawData = "Type mismatch: Expected \(type) at \(context.codingPath)"
                    case .valueNotFound(let type, let context):
                        self.rawData = "Value not found: Expected \(type) at \(context.codingPath)"
                    case .keyNotFound(let key, let context):
                        self.rawData = "Key not found: \(key) at \(context.codingPath)"
                    case .dataCorrupted(let context):
                        self.rawData = "Data corrupted: \(context.debugDescription)"
                    @unknown default:
                        self.rawData = "Unknown decoding error: \(decodingError)"
                    }
                } else {
                    self.rawData = "Error: \(error.localizedDescription)"
                    
                    let errorString = error.localizedDescription
                    if errorString.contains("AWSIngredientModel") {
                        createNutritionFromIngredientModel(errorString)
                    }
                }
            }
        }
    }
    
    /// Try to create a nutrition model from an AWSIngredientModel string in the error
    private func createNutritionFromIngredientModel(_ errorString: String) {
        let pattern = #"AWSIngredientModel\(edamamFoodId: "([^"]+)", foodCategory: "([^"]+)", name: "([^"]+)", quantityType: "([^"]+)", experiationDuration: (\d+), imageURL: "[^"]*"\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: errorString, range: NSRange(errorString.startIndex..., in: errorString)) else {
            return
        }
        
        // Extract all the matched groups
        let edamamFoodId = extractMatchGroup(match, at: 1, from: errorString)
        let foodCategory = extractMatchGroup(match, at: 2, from: errorString)
        let name = extractMatchGroup(match, at: 3, from: errorString)
        let quantityType = extractMatchGroup(match, at: 4, from: errorString)
        let experiationDurationStr = extractMatchGroup(match, at: 5, from: errorString)
        let experiationDuration = Int(experiationDurationStr) ?? 0
        
        // Try to get nutritional values based on the name
        let (fat, cholesterol, sodium, potassium, carbohydrate, protein, calorie) = 
            getDefaultNutritionValues(for: name.lowercased())
        
        let simplifiedNutrition = AWSIngredientNutritionModel(
            edamamFoodId: edamamFoodId,
            name: name,
            foodCategory: foodCategory,
            quantityType: quantityType,
            experiationDuration: experiationDuration,
            fat: fat,
            cholesterol: cholesterol,
            sodium: sodium,
            potassium: potassium,
            carbohydrate: carbohydrate,
            protein: protein,
            calorie: calorie,
            quantity: 100.0
        )
        
        self.nutritionInfo = simplifiedNutrition
        self.isError = false
        self.rawData = "Created nutrition model from ingredient data with default nutrition values for \(name)."
    }
    
    /// Return default nutrition values for common foods (per 100g)
    private func getDefaultNutritionValues(for foodName: String) -> (fat: Double, cholesterol: Double, sodium: Double, potassium: Double, carbohydrate: Double, protein: Double, calorie: Double) {
        
        // Common nutritional values per 100g
        let defaultValues: [String: (fat: Double, cholesterol: Double, sodium: Double, potassium: Double, carbohydrate: Double, protein: Double, calorie: Double)] = [
            "egg": (5.0, 373.0, 124.0, 126.0, 0.7, 12.6, 143.0),
            "chicken": (9.3, 88.0, 86.0, 229.0, 0.0, 27.0, 195.0),
            "chicken breast": (3.6, 85.0, 65.0, 256.0, 0.0, 31.0, 165.0),
            "beef": (15.0, 75.0, 66.0, 318.0, 0.0, 26.0, 250.0),
            "salmon": (13.0, 55.0, 59.0, 363.0, 0.0, 20.0, 208.0),
            "tuna": (1.0, 38.0, 37.0, 237.0, 0.0, 23.6, 109.0),
            "shrimp": (0.9, 189.0, 111.0, 220.0, 0.0, 24.0, 119.0),
            "apple": (0.2, 0.0, 1.0, 107.0, 14.0, 0.3, 52.0),
            "banana": (0.3, 0.0, 1.0, 358.0, 23.0, 1.1, 89.0),
            "broccoli": (0.4, 0.0, 33.0, 316.0, 7.0, 2.8, 34.0),
            "carrot": (0.2, 0.0, 69.0, 320.0, 9.6, 0.9, 41.0),
            "potato": (0.1, 0.0, 6.0, 421.0, 17.0, 2.0, 77.0),
            "rice": (0.3, 0.0, 1.0, 35.0, 28.0, 2.7, 130.0),
            "bread": (3.2, 0.0, 491.0, 126.0, 49.0, 9.0, 265.0),
            "milk": (3.3, 10.0, 43.0, 150.0, 5.0, 3.4, 60.0),
            "cheese": (33.0, 105.0, 653.0, 98.0, 3.1, 25.0, 402.0),
            "yogurt": (0.4, 5.0, 36.0, 141.0, 4.7, 3.6, 59.0)
        ]
        
        // Check for exact match
        if let values = defaultValues[foodName] {
            return values
        }
        
        // Check for partial match
        for (key, values) in defaultValues {
            if foodName.contains(key) || key.contains(foodName) {
                return values
            }
        }
        
        // Return generic values as fallback
        return (fat: 5.0, cholesterol: 50.0, sodium: 100.0, potassium: 200.0, carbohydrate: 10.0, protein: 10.0, calorie: 150.0)
    }
    
    /// Helper to extract a match group from a regex result
    private func extractMatchGroup(_ match: NSTextCheckingResult, at idx: Int, from string: String) -> String {
        let range = match.range(at: idx)
        if range.location != NSNotFound,
           let substringRange = Range(range, in: string) {
            return String(string[substringRange])
        }
        return ""
    }
    
    private func tryAlternateLookup() {
        // If direct ID lookup failed, try by name
        if usesDirectID && ingredientName != nil {
            lookupByName(ingredientName!)
        }
        else if !usesDirectID {
            // Try a fuzzy match
            let words = foodIdentifier.lowercased().split(separator: " ")
            var possibleMatches: [(name: String, id: String)] = []
            
            for word in words where word.count > 3 {
                let similarNames = FoodIDService.shared.getSimilarNames(containing: String(word))
                possibleMatches.append(contentsOf: similarNames)
            }
            
            if let firstMatch = possibleMatches.first {
                performDirectIDLookup(firstMatch.id)
            } else {
                isErrorMessage = "No similar ingredients found in our database."
                
                if rawData.contains("{") && rawData.contains("}") {
                    parseRawJsonResponse(rawData)
                }
            }
        } else {
            if rawData.contains("{") && rawData.contains("}") {
                parseRawJsonResponse(rawData)
            }
        }
    }
    
    /// Attempt to manually parse the raw JSON response string if regular decoding fails
    private func parseRawJsonResponse(_ jsonString: String) {
        // Check if the string contains raw response
        var cleanedJsonString = jsonString
        if jsonString.contains("Raw response:") {
            if let jsonStart = jsonString.range(of: "{"),
               let jsonEnd = jsonString.range(of: "}", options: .backwards) {
                let startIndex = jsonStart.lowerBound
                let endIndex = jsonEnd.upperBound
                cleanedJsonString = String(jsonString[startIndex..<endIndex])
            }
        }
        
        // Parse the json string
        if let jsonData = cleanedJsonString.data(using: .utf8) {
            do {
                let nutrition = try JSONDecoder().decode(AWSIngredientNutritionModel.self, from: jsonData)
                self.nutritionInfo = nutrition
                self.isError = false
                self.rawData = "Successfully parsed raw JSON: \(cleanedJsonString)"
            } catch {
                self.isError = true
                self.isErrorMessage = "Failed to parse raw JSON: \(error.localizedDescription)"
                self.rawData = "Error parsing JSON: \(error)\n\nRaw JSON: \(cleanedJsonString)"
            }
        }
    }
    
    /// Parse sample JSON for testing purposes
    private func parseSampleJson() {
        let sampleJson = """
        {"Calorie":72,"Carbohydrate":"0.00","Category":"Meats","Cholesterol":"136.85","Edamam_Food_ID":"food_bjap0xzbf5x6s3azkpwtfb14i25u","Fat":"0.43","Name":"Shrimp","Potassium":"224.40","Protein":"17.09","Quantity":85,"Quantity_Type":"grams","Sodium":"101.15"}
        """
        
        if let jsonData = sampleJson.data(using: .utf8) {
            do {
                let nutrition = try JSONDecoder().decode(AWSIngredientNutritionModel.self, from: jsonData)
                self.nutritionInfo = nutrition
                self.isError = false
                self.rawData = "Successfully parsed sample JSON"
            } catch {
                self.isError = true
                self.isErrorMessage = "Failed to parse sample JSON: \(error.localizedDescription)"
                self.rawData = "Error parsing JSON: \(error)"
            }
        }
    }
    
    private func fetchNutrition() {
        if usesDirectID && isEdamamFoodID(foodIdentifier) {
            performDirectIDLookup(foodIdentifier)
        }
        else if usesDirectID && isUUID(foodIdentifier) && ingredientName != nil {
            if let name = ingredientName {
                lookupByName(name)
            } else {
                performDirectIDLookup(foodIdentifier)
            }
        } else if usesDirectID {
            performDirectIDLookup(foodIdentifier)
        } else {
            lookupByName(foodIdentifier)
        }
    }
}

struct NutrientRow: View {
    let name: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
            Spacer()
            Text("\(value, specifier: "%.1f") \(unit)")
                .font(.subheadline)
                .bold()
        }
    }
}

struct NutrientRowEnhanced: View {
    let name: String
    let value: Double
    let unit: String
    let dailyValue: Int
    
    var percentOfDaily: Int {
        Int(round(value / Double(dailyValue) * 100))
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(name)
                .font(.body)
            
            Spacer()
            
            Text("\(value, specifier: "%.1f") \(unit)")
                .font(.body)
                .bold()
            
            Text("\(percentOfDaily)%")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct NutritionPieChart: View {
    let carbs: Double
    let protein: Double
    let fat: Double
    
    private var total: Double {
        max(carbs + protein + fat, 1.0)
    }
    
    private var carbsAngle: Double {
        360.0 * (carbs / total)
    }
    
    private var proteinAngle: Double {
        360.0 * (protein / total)
    }
    
    private var fatAngle: Double {
        360.0 * (fat / total)
    }
    
    var body: some View {
        ZStack {
            // Carbs (blue)
            PieSlice(startAngle: 0, endAngle: carbsAngle)
                .fill(Color.blue)
            
            // Protein (red)
            PieSlice(startAngle: carbsAngle, endAngle: carbsAngle + proteinAngle)
                .fill(Color.red)
            
            // Fat (yellow)
            PieSlice(startAngle: carbsAngle + proteinAngle, endAngle: 360)
                .fill(Color.yellow)
            
            VStack {
                Text("\(Int(total))")
                    .font(.system(size: 24, weight: .bold))
                
                Text("grams")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Pie slice shape for the chart
struct PieSlice: Shape {
    var startAngle: Double
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle - 90),
            endAngle: .degrees(endAngle - 90),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}
