import SwiftUI

/// A demonstration component that shows how to handle UUID-formatted food IDs
struct UUIDFoodLookupDemo: View {
    @EnvironmentObject var userSession: UserSession
    @State private var ingredientName: String = ""
    @State private var fakeUUID: String = UUID().uuidString
    @State private var showNutritionInfo = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("UUID Food ID Fallback Demo")
                .font(.headline)
            
            Text("This demo shows how the system handles UUID-formatted IDs by falling back to name-based lookup")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            TextField("Enter ingredient name", text: $ingredientName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Mock UUID: \(fakeUUID)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Generate New UUID") {
                fakeUUID = UUID().uuidString
            }
            .font(.caption)
            .padding(.bottom)
            
            Button(action: {
                showNutritionInfo = true
            }) {
                Text("Show Nutrition Info")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(ingredientName.isEmpty)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("What happens:")
                    .font(.subheadline)
                    .bold()
                
                Text("1. We send a UUID-formatted ID to the NutritionFactsPopup")
                    .font(.caption)
                
                Text("2. The popup detects this is not an Edamam food ID format")
                    .font(.caption)
                
                Text("3. It falls back to looking up the food by name in the foodID.json file")
                    .font(.caption)
                
                Text("4. If found, it uses the correct Edamam ID to fetch nutrition data")
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showNutritionInfo) {
            // Pass the UUID as the ID, but also provide the ingredient name
            // The nutrition facts popup will detect the UUID format and use the name instead
            NutritionFactsPopup(
                foodId: fakeUUID,
                userSession: userSession,
                ingredientName: ingredientName
            )
        }
    }
}

struct UUIDFoodLookupDemo_Previews: PreviewProvider {
    static var previews: some View {
        UUIDFoodLookupDemo()
            .environmentObject(UserSession())
    }
} 