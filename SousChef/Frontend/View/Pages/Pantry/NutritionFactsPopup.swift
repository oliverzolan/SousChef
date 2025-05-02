import SwiftUI

struct NutritionFactsPopup: View {
    let foodName: String
    let foodCategory: String
    
    // Don't use user session or any complex state
    init(foodId: String, userSession: UserSession, ingredientName: String? = nil) {
        let name = ingredientName ?? foodId
        self.foodName = name
        self.foodCategory = NutritionFactsPopup.getFoodCategory(for: name.lowercased())
    }
    
    init(foodName: String, userSession: UserSession) {
        self.foodName = foodName
        self.foodCategory = NutritionFactsPopup.getFoodCategory(for: foodName.lowercased())
    }
    
    var body: some View {
        // Get nutrition values
        let (calories, protein, carbs, fat) = getFoodNutrition(for: foodName.lowercased())
        let (cholesterol, sodium, potassium) = getAdditionalNutrition(for: foodName.lowercased())
        
        // Calculate total macronutrients for the pie chart
        let totalMacros = Double(protein + carbs + fat)
        
        // Calculate percentages for the pie chart
        let proteinPercent = totalMacros > 0 ? Double(protein) / totalMacros : 0.33
        let carbsPercent = totalMacros > 0 ? Double(carbs) / totalMacros : 0.33
        let fatPercent = totalMacros > 0 ? Double(fat) / totalMacros : 0.34
        
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 28) {
                    // Food name and category
                    VStack(spacing: 10) {
                        Text(foodName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 22)
                                
                        Text("Category: \(foodCategory)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 42)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Nutrition wheel box
                    VStack(spacing: 24) {
                        Text("Nutrition Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Legend first for better clarity
                        HStack {
                            Spacer()
                            
                            ForEach([
                                (color: Color.red, name: "Protein"),
                                (color: Color.blue, name: "Carbs"),
                                (color: Color.yellow, name: "Fat")
                            ], id: \.name) { item in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 16, height: 16)
                                    Text(item.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // For larger screens, show wheel and macros side by side
                        // For smaller screens, stack them vertically
                        if geometry.size.width > 500 {
                            HStack(alignment: .center, spacing: 30) {
                                nutritionWheel(calories: calories, proteinPercent: proteinPercent, carbsPercent: carbsPercent, fatPercent: fatPercent)
                                
                                // Legend and macronutrient values
                                VStack(alignment: .leading, spacing: 22) {
                                    MacroRow(color: .red, name: "Protein", value: protein, unit: "g")
                                    MacroRow(color: .blue, name: "Carbs", value: carbs, unit: "g")
                                    MacroRow(color: .yellow, name: "Fat", value: fat, unit: "g")
                                }
                                .padding(.trailing)
                            }
                            .padding(.bottom, 30)
                        } else {
                            VStack(spacing: 24) {
                                nutritionWheel(calories: calories, proteinPercent: proteinPercent, carbsPercent: carbsPercent, fatPercent: fatPercent)
                                
                                // Legend and macronutrient values in horizontal layout for small screens
                                VStack(alignment: .leading, spacing: 22) {
                                    MacroRow(color: .red, name: "Protein", value: protein, unit: "g")
                                    MacroRow(color: .blue, name: "Carbs", value: carbs, unit: "g")
                                    MacroRow(color: .yellow, name: "Fat", value: fat, unit: "g")
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                    
                    // Macronutrient Breakdown
                    VStack(spacing: 24) {
                        Text("Macronutrient Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Protein bar
                        NutrientProgressBar(
                            label: "Protein",
                            value: protein,
                            total: Int(totalMacros),
                            unit: "g",
                            color: .red
                        )
                        
                        // Carbs bar
                        NutrientProgressBar(
                            label: "Carbohydrates",
                            value: carbs,
                            total: Int(totalMacros),
                            unit: "g",
                            color: .blue
                        )
                        
                        // Fat bar
                        NutrientProgressBar(
                            label: "Fat",
                            value: fat,
                            total: Int(totalMacros),
                            unit: "g",
                            color: .yellow
                        )
                        
                        // Percentage breakdown
                        HStack(spacing: 0) {
                            ForEach([
                                (label: "Protein", value: proteinPercent, color: Color.red),
                                (label: "Carbs", value: carbsPercent, color: Color.blue),
                                (label: "Fat", value: fatPercent, color: Color.yellow)
                            ], id: \.label) { item in
                                VStack(spacing: 6) {
                                    Text("\(Int(item.value * 100))%")
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    Text(item.label)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(item.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                    
                    // Additional Nutrients
                    VStack(spacing: 24) {
                        Text("Additional Nutrients")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // For larger screens, use grid layout
                        if geometry.size.width > 500 {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                NutrientCard(name: "Cholesterol", value: cholesterol, unit: "mg")
                                NutrientCard(name: "Sodium", value: sodium, unit: "mg")
                                NutrientCard(name: "Potassium", value: potassium, unit: "mg")
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 30)
                        } else {
                            HStack(spacing: 0) {
                                // Cholesterol card
                                NutrientCard(
                                    name: "Cholesterol",
                                    value: cholesterol,
                                    unit: "mg"
                                )
                                
                                // Sodium card
                                NutrientCard(
                                    name: "Sodium",
                                    value: sodium,
                                    unit: "mg"
                                )
                                
                                // Potassium card
                                NutrientCard(
                                    name: "Potassium",
                                    value: potassium,
                                    unit: "mg"
                                )
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                    
                    // Food Benefits
                    VStack(spacing: 14) {
                        Text("Food Benefits")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        Text(getFoodBenefits(for: foodName.lowercased(), category: foodCategory))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                    
                    // Data source note
                    Text("Note: Food data sourced from USDA Food Database and nutritional guidelines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 24)
                }
                .padding(.vertical, 24)
                .frame(width: geometry.size.width)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                print("Full-screen nutrition view appeared for \(foodName)")
            }
        }
    }
    
    // Extracted the nutrition wheel to a separate function for reuse
    private func nutritionWheel(calories: Int, proteinPercent: Double, carbsPercent: Double, fatPercent: Double) -> some View {
        ZStack {
            // Draw the pie chart segments
            Circle()
                .trim(from: 0, to: CGFloat(proteinPercent))
                .stroke(Color.red, lineWidth: 45)
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: CGFloat(carbsPercent))
                .stroke(Color.blue, lineWidth: 45)
                .rotationEffect(.degrees(-90 + 360 * proteinPercent))
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: CGFloat(fatPercent))
                .stroke(Color.yellow, lineWidth: 45)
                .rotationEffect(.degrees(-90 + 360 * (proteinPercent + carbsPercent)))
                .frame(width: 200, height: 200)
            
            // Center text with calorie count
            VStack {
                Text("\(calories)")
                    .font(.system(size: 34, weight: .bold))
                
                Text("CALORIES")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200, height: 200)
        .padding()
    }
    
    // Get food benefits based on food category
    // Food descriptions are generated based on category using a predefined template
    private func getFoodBenefits(for name: String, category: String) -> String {
        switch category {
        case "Vegetables":
            return "\(foodName) is rich in vitamins, minerals, and dietary fiber. Vegetables are generally low in calories and fat, making them an excellent choice for a healthy diet. They contain antioxidants that help protect your cells from damage."
        case "Fruits":
            return "\(foodName) contains natural sugars, fiber, and various essential nutrients. Fruits are packed with vitamins, particularly vitamin C, and antioxidants that can help reduce the risk of chronic diseases."
        case "Meats":
            return "\(foodName) is a good source of high-quality protein, iron, zinc, and B-vitamins. Protein is essential for building and repairing tissues, and supporting immune function."
        case "Seafood":
            return "\(foodName) is typically high in protein and omega-3 fatty acids, which are beneficial for heart health. Seafood is also rich in essential nutrients like vitamin D and selenium."
        case "Grains":
            return "\(foodName) provides complex carbohydrates, fiber, and essential nutrients. Whole grains in particular can help reduce the risk of heart disease, type 2 diabetes, and maintain digestive health."
        case "Dairy":
            return "\(foodName) is rich in calcium, protein, and often fortified with vitamin D. These nutrients are important for bone health, muscle function, and immune support."
        case "Spices":
            return "\(foodName) can add flavor to dishes without adding significant calories. Many spices contain compounds with anti-inflammatory and antioxidant properties."
        case "Condiments":
            return "\(foodName) adds flavor to meals. Using condiments moderately can enhance the taste of food while being mindful of added sugars, sodium, or fats."
        default:
            return "\(foodName) is part of a balanced diet. Different foods provide various nutrients that your body needs for overall health and wellbeing."
        }
    }
    
    // Helper functions
    private static func getFoodCategory(for name: String) -> String {
        let vegetables = ["tomato", "broccoli", "carrot", "spinach", "kale", "potato", "garlic", 
                         "bell pepper", "corn", "endive", "lettuce", "celery", "onion", "green bean",
                         "asparagus", "cabbage", "cucumber", "eggplant", "zucchini", "squash", "pumpkin"]
        
        let fruits = ["apple", "banana", "orange", "pineapple", "grape", "strawberry", 
                      "blueberry", "avocado", "coconut", "mango", "watermelon", "kiwi", "peach",
                      "pear", "plum", "cherry", "lemon", "lime", "grapefruit", "raspberry", "blackberry"]
        
        let meats = ["chicken", "beef", "pork", "bacon", "ham", "turkey", "sausage", "lamb",
                    "steak", "ground beef", "brisket", "ribs", "veal", "venison", "duck"]
        
        let seafood = ["salmon", "tuna", "shrimp", "crab", "lobster", "cod", "tilapia",
                       "trout", "halibut", "sardine", "anchovy", "mackerel", "oyster", "clam", "mussel", "scallop"]
                       
        let grains = ["rice", "bread", "pasta", "oat", "barley", "quinoa", "couscous", "cereal",
                     "wheat", "bulgur", "rye", "buckwheat", "millet", "corn", "tortilla"]
                     
        let dairy = ["milk", "cheese", "yogurt", "butter", "cream", "ice cream", "cottage cheese",
                    "sour cream", "cream cheese", "cheddar", "mozzarella", "parmesan", "brie"]
                    
        let spices = ["salt", "pepper", "oregano", "basil", "thyme", "rosemary", "cinnamon",
                     "cumin", "curry", "paprika", "chili", "nutmeg", "ginger", "turmeric", "cardamom"]
                     
        let condiments = ["ketchup", "mustard", "mayonnaise", "sauce", "dressing", "vinegar",
                         "oil", "honey", "syrup", "jam", "jelly", "salsa", "relish", "soy sauce"]
        
        // Check for matches in each category
        if containsAny(name, words: vegetables) { return "Vegetables" }
        if containsAny(name, words: fruits) { return "Fruits" }
        if containsAny(name, words: meats) { return "Meats" }
        if containsAny(name, words: seafood) { return "Seafood" }
        if containsAny(name, words: grains) { return "Grains" }
        if containsAny(name, words: dairy) { return "Dairy" }
        if containsAny(name, words: spices) { return "Spices" }
        if containsAny(name, words: condiments) { return "Condiments" }
        
        return "Other"
    }
    
    // Helper function to check if a string contains any word from a list
    private static func containsAny(_ text: String, words: [String]) -> Bool {
        for word in words {
            if text.contains(word) || word.contains(text) {
                return true
            }
        }
        return false
    }
    
    private func getFoodNutrition(for name: String) -> (calories: Int, protein: Int, carbs: Int, fat: Int) {
        let nutrition: [String: (calories: Int, protein: Int, carbs: Int, fat: Int)] = [
            // Vegetables
            "tomato": (18, 1, 4, 0),
            "broccoli": (34, 3, 7, 0),
            "carrot": (41, 1, 10, 0),
            "spinach": (23, 3, 4, 0),
            "kale": (49, 4, 9, 1),
            "potato": (77, 2, 17, 0),
            "garlic": (149, 6, 33, 1),
            "bell pepper": (30, 1, 7, 0),
            "corn": (86, 3, 19, 1),
            "endive": (17, 1, 3, 0),
            "lettuce": (15, 1, 3, 0),
            "celery": (16, 1, 3, 0),
            "onion": (40, 1, 9, 0),
            "green bean": (31, 2, 7, 0),
            "asparagus": (20, 2, 4, 0),
            "cucumber": (15, 1, 3, 0),
            "eggplant": (25, 1, 6, 0),
            "zucchini": (17, 1, 3, 0),
            
            // Fruits
            "apple": (52, 0, 14, 0),
            "banana": (89, 1, 23, 0),
            "orange": (47, 1, 12, 0),
            "pineapple": (50, 1, 13, 0),
            "grape": (69, 1, 18, 0),
            "strawberry": (32, 1, 8, 0),
            "blueberry": (57, 1, 14, 0),
            "avocado": (160, 2, 9, 15),
            "coconut": (354, 3, 15, 33),
            "mango": (60, 1, 15, 0),
            "watermelon": (30, 1, 8, 0),
            "kiwi": (61, 1, 15, 1),
            "peach": (39, 1, 10, 0),
            "lemon": (29, 1, 9, 0),
            
            // Meats
            "chicken": (165, 31, 0, 4),
            "beef": (250, 26, 0, 15),
            "pork": (242, 26, 0, 14),
            "bacon": (541, 37, 1, 42),
            "ham": (145, 21, 1, 5),
            "turkey": (189, 29, 0, 7),
            "sausage": (301, 16, 3, 25),
            "lamb": (294, 25, 0, 21),
            "steak": (271, 25, 0, 19),
            "ground beef": (250, 26, 0, 15),
            "duck": (337, 19, 0, 28),
            
            // Seafood
            "salmon": (208, 20, 0, 13),
            "tuna": (109, 24, 0, 1),
            "shrimp": (119, 24, 0, 1),
            "crab": (97, 19, 0, 2),
            "lobster": (89, 19, 0, 1),
            "cod": (82, 18, 0, 1),
            "tilapia": (128, 26, 0, 3),
            "trout": (190, 27, 0, 8),
            "halibut": (111, 23, 0, 2),
            
            // Specific cuts
            "chicken breast": (165, 31, 0, 4),
            "chicken wings": (290, 27, 0, 19),
            
            // Dairy
            "milk": (60, 3, 5, 3),
            "cheese": (402, 25, 3, 33),
            "yogurt": (59, 4, 5, 0),
            "butter": (717, 1, 0, 81),
            "cream": (340, 2, 7, 33),
            
            // Grains
            "rice": (130, 3, 28, 0),
            "bread": (265, 9, 49, 3),
            "pasta": (131, 5, 25, 1),
            "oat": (389, 17, 66, 7),
            "quinoa": (120, 4, 21, 2),
            
            // Other
            "egg": (143, 13, 1, 10),
            "honey": (304, 0, 82, 0),
            "olive oil": (884, 0, 0, 100),
            "sugar": (387, 0, 100, 0),
            "chocolate": (546, 5, 61, 31),
            "peanut butter": (588, 25, 20, 50)
        ]
        
        // Check for exact match first
        if let exact = nutrition[name] {
            return exact
        }
        
        // Check for partial match
        for (key, value) in nutrition {
            if name.contains(key) || key.contains(name) {
                return value
            }
        }
        
        // Return standard values if no match found
        return (120, 5, 10, 5)
    }
    
    // Get additional nutrition info
    private func getAdditionalNutrition(for name: String) -> (cholesterol: Int, sodium: Int, potassium: Int) {
        let additionalNutrition: [String: (cholesterol: Int, sodium: Int, potassium: Int)] = [
            // Vegetables
            "tomato": (0, 5, 237),
            "broccoli": (0, 33, 316),
            "carrot": (0, 69, 320),
            "spinach": (0, 79, 558),
            "kale": (0, 53, 491),
            "potato": (0, 6, 421),
            "bell pepper": (0, 4, 211),
            "corn": (0, 15, 270),
            "cucumber": (0, 2, 147),
            "onion": (0, 4, 146),
            "garlic": (0, 17, 401),
            "zucchini": (0, 8, 295),
            "eggplant": (0, 2, 229),
            "asparagus": (0, 2, 202),
            
            // Fruits
            "apple": (0, 1, 107),
            "banana": (0, 1, 358),
            "orange": (0, 0, 181),
            "avocado": (0, 7, 485),
            "pineapple": (0, 1, 109),
            "grape": (0, 2, 191),
            "strawberry": (0, 1, 153),
            "blueberry": (0, 1, 77),
            "watermelon": (0, 2, 112),
            "peach": (0, 0, 190),
            "kiwi": (0, 3, 312),
            "mango": (0, 2, 168),
            "lemon": (0, 2, 138),
            
            // Meats
            "chicken": (85, 65, 256),
            "beef": (75, 66, 318),
            "pork": (80, 65, 340),
            "bacon": (110, 1900, 240),
            "ham": (53, 1203, 270),
            "turkey": (65, 68, 252),
            "sausage": (65, 800, 315),
            "lamb": (83, 65, 310),
            "steak": (77, 56, 323),
            "ground beef": (78, 76, 305),
            "duck": (84, 59, 271),
            "chicken breast": (85, 65, 256),
            "chicken wings": (93, 86, 243),
            
            // Seafood
            "salmon": (55, 59, 363),
            "tuna": (38, 37, 237),
            "shrimp": (189, 111, 220),
            "crab": (78, 320, 275),
            "lobster": (95, 323, 300),
            "cod": (43, 58, 302),
            "tilapia": (57, 56, 302),
            "trout": (63, 58, 375),
            "halibut": (41, 59, 490),
            
            // Dairy
            "milk": (10, 43, 150),
            "cheese": (105, 653, 98),
            "yogurt": (12, 56, 234),
            "butter": (215, 714, 24),
            "cream": (166, 104, 28),
            
            // Grains
            "rice": (0, 5, 55),
            "bread": (0, 450, 107),
            "pasta": (0, 1, 61),
            "oat": (0, 2, 165),
            "quinoa": (0, 7, 172),
            
            // Others
            "egg": (373, 124, 126),
            "honey": (0, 4, 52),
            "olive oil": (0, 2, 1),
            "peanut butter": (0, 156, 208)
        ]
        
        // Check for exact match first
        if let exact = additionalNutrition[name] {
            return exact
        }
        
        // Check for partial match
        for (key, value) in additionalNutrition {
            if name.contains(key) || key.contains(name) {
                return value
            }
        }
        
        // Standard values if no match found
        return (20, 80, 200)
    }
}

// Macro nutrient row with color indicator
struct MacroRow: View {
    let color: Color
    let name: String
    let value: Int
    let unit: String
    
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(color)
                .frame(width: 18, height: 18)
            
            Text(name)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Text("\(value)\(unit)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color.opacity(0.9))
        }
        .padding(.vertical, 8)
    }
}

// Nutrient progress bar
struct NutrientProgressBar: View {
    let label: String
    let value: Int
    let total: Int
    let unit: String
    let color: Color
    
    var percentage: CGFloat {
        if total <= 0 { return 0.05 }
        return min(CGFloat(value) / CGFloat(total), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(value)\(unit)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color.opacity(0.9))
            }
            .padding(.bottom, 4)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 16)
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(color)
                    .frame(width: max(24, UIScreen.main.bounds.width * 0.7 * percentage), height: 16)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// Nutrient card for additional nutrients
struct NutrientCard: View {
    let name: String
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .padding(.vertical, 4)
            
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
        .padding(.horizontal, 4)
    }
}
