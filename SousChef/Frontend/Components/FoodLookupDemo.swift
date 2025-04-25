import SwiftUI

/// A demonstration component that shows how to use the FoodIDService
struct FoodLookupDemo: View {
    @EnvironmentObject var userSession: UserSession
    @State private var foodName: String = ""
    @State private var foodId: String? = nil
    @State private var showNutritionInfo = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Food ID Lookup")
                .font(.headline)
            
            TextField("Enter food name", text: $foodName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: lookupFoodId) {
                Text("Look up ID")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let id = foodId {
                VStack(alignment: .leading) {
                    Text("Found ID: \(id)")
                        .font(.subheadline)
                    
                    Button("View Nutrition Facts") {
                        showNutritionInfo = true
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showNutritionInfo) {
            if let id = foodId {
                NutritionFactsPopup(foodId: id, userSession: userSession)
            }
        }
    }
    
    private func lookupFoodId() {
        guard !foodName.isEmpty else { return }
        
        if let id = FoodIDService.shared.getFoodID(for: foodName) {
            self.foodId = id
        } else {
            // Show a notification that ID wasn't found
            self.foodId = nil
            
            // Could show an alert here
            print("No food ID found for \(foodName)")
        }
    }
}

struct FoodLookupDemo_Previews: PreviewProvider {
    static var previews: some View {
        FoodLookupDemo()
            .environmentObject(UserSession())
    }
} 