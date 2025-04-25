import SwiftUI

/// A utility view to debug food ID issues
struct FoodIDDebugView: View {
    @State private var filePaths: [String: Bool] = [:]
    @State private var eggID: String = "Not tested"
    @State private var lookupResults: [String] = []
    @State private var loadedInfo: String = "Not checked"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Food ID Debug Information")
                    .font(.headline)
                
                // File status section
                VStack(alignment: .leading, spacing: 8) {
                    Text("File Status")
                        .font(.subheadline)
                        .bold()
                    
                    Button("Check Food ID Status") {
                        checkFoodIDStatus()
                    }
                    
                    Text(loadedInfo)
                        .font(.system(.caption, design: .monospaced))
                        .padding(.top, 4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // First section: Basic tests
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basic Tests")
                        .font(.subheadline)
                        .bold()
                    
                    Button("Test Egg ID Lookup") {
                        if let id = FoodIDService.shared.getFoodID(for: "Egg") {
                            eggID = id
                        } else {
                            eggID = "Not found"
                        }
                    }
                    
                    Text("Egg ID: \(eggID)")
                        .font(.system(.body, design: .monospaced))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Second section: File paths
                VStack(alignment: .leading, spacing: 8) {
                    Text("File Paths")
                        .font(.subheadline)
                        .bold()
                    
                    Button("Check File Paths") {
                        filePaths = FoodIDService.shared.debugFilePaths()
                    }
                    
                    if !filePaths.isEmpty {
                        ForEach(filePaths.sorted(by: { $0.key < $1.key }), id: \.key) { path, exists in
                            HStack {
                                Image(systemName: exists ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(exists ? .green : .red)
                                
                                Text(path)
                                    .font(.system(.caption, design: .monospaced))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(exists ? "EXISTS" : "NOT FOUND")
                                    .font(.caption)
                                    .foregroundColor(exists ? .green : .red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Third section: Test various food items
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Multiple Foods")
                        .font(.subheadline)
                        .bold()
                    
                    Button("Test Common Foods") {
                        lookupResults = []
                        testCommonFoods()
                    }
                    
                    ForEach(lookupResults, id: \.self) { result in
                        Text(result)
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            // Automatically run checks when view appears
            checkFoodIDStatus()
            filePaths = FoodIDService.shared.debugFilePaths()
            if let id = FoodIDService.shared.getFoodID(for: "Egg") {
                eggID = id
            } else {
                eggID = "Not found"
            }
        }
    }
    
    private func checkFoodIDStatus() {
        // Check if we can load the food IDs
        let egg = FoodIDService.shared.getFoodID(for: "Egg")
        let apple = FoodIDService.shared.getFoodID(for: "Apple") 
        let banana = FoodIDService.shared.getFoodID(for: "Banana")
        let potato = FoodIDService.shared.getFoodID(for: "Potato")
        
        // Count how many items are successfully loaded
        let loadedCount = FoodIDService.shared.getLoadedCount()
        let isHardcoded = FoodIDService.shared.isUsingHardcodedData()
        
        if isHardcoded {
            loadedInfo = "⚠️ Using hardcoded data with \(loadedCount) items\nEgg: \(egg ?? "Not found")\nApple: \(apple ?? "Not found")\nBanana: \(banana ?? "Not found")"
        } else {
            loadedInfo = "✅ Loaded \(loadedCount) items from JSON file\nEgg: \(egg ?? "Not found")\nApple: \(apple ?? "Not found")\nBanana: \(banana ?? "Not found")"
        }
    }
    
    private func testCommonFoods() {
        let foods = ["Apple", "Banana", "Egg", "Potato", "Chicken", "Milk", "Cheese", "Bread", "Rice", "Tomato"]
        
        for food in foods {
            if let id = FoodIDService.shared.getFoodID(for: food) {
                lookupResults.append("\(food): ✅ (\(id))")
            } else {
                lookupResults.append("\(food): ❌ (Not found)")
            }
        }
    }
}

struct FoodIDDebugView_Previews: PreviewProvider {
    static var previews: some View {
        FoodIDDebugView()
    }
} 