import SwiftUI

// Shows ingredient name, a quantity field, and a button to show nutrition info.
struct IngredientRow: View {
    let ingredient: String
    @State private var quantity: String = "1"
    @State private var showNutritionSheet: Bool = false

    var body: some View {
        HStack {
            Text(ingredient)
                .font(.body)
            Spacer()
            TextField("Qty", text: $quantity)
                .frame(width: 50)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            Button {
                showNutritionSheet.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showNutritionSheet) {
                NutritionFactsPopup(ingredient: ingredient)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct BaseIngredientsPage: View {
    let title: String
    let ingredients: [String]
    
    @EnvironmentObject var userSession: UserSession
    @State private var showAddIngredientSheet = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(ingredients, id: \.self) { ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showAddIngredientSheet = true
            }) {
                Text("Add Ingredient")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAddIngredientSheet) {
            AddIngredientPopup(ingredients: .constant([]), scannedIngredient: nil, userSession: userSession)
        }
    }
}

struct BaseIngredientsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BaseIngredientsPage(
                title: "Ingredients",
                ingredients: ["Carrots", "Broccoli", "Spinach"]
            )
        }
    }
}
