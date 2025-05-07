import SwiftUI

struct EnrichedIngredientsView: View {
    @Binding var ingredients: [RecognizedIngredientWithDetails]
    @State private var searchText: String = ""
    
    var filteredIngredients: [RecognizedIngredientWithDetails] {
        if searchText.isEmpty {
            return ingredients
        } else {
            return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            if ingredients.isEmpty {
                emptyStateView
            } else {
                searchField
                ingredientsList
                actionButtons
            }
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search ingredients", text: $searchText)
                .padding(.vertical, 8)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var ingredientsList: some View {
        List {
            ForEach(filteredIngredients.indices, id: \.self) { index in
                if index < ingredients.count {
                    let bindingIngredient = Binding(
                        get: { self.ingredients[index] },
                        set: { self.ingredients[index] = $0 }
                    )
                    
                    EnrichedIngredientRow(ingredient: bindingIngredient)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var actionButtons: some View {
        HStack {
            Button(action: {
                for i in 0..<ingredients.count {
                    ingredients[i].selected = true
                }
            }) {
                Text("Select All")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Button(action: {
                for i in 0..<ingredients.count {
                    ingredients[i].selected = false
                }
            }) {
                Text("Deselect All")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No ingredients recognized")
                .font(.headline)
            
            Text("Try taking a clearer photo or using a different image")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EnrichedIngredientRow: View {
    @Binding var ingredient: RecognizedIngredientWithDetails
    
    var body: some View {
        HStack {
            Button(action: {
                ingredient.selected.toggle()
            }) {
                Image(systemName: ingredient.selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(ingredient.selected ? AppColors.primary1 : .gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name.capitalized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ingredient.selected ? .primary : .gray)
                
                Text(ingredient.category)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            if !ingredient.imageURL.isEmpty {
                AsyncImage(url: URL(string: ingredient.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .frame(width: 40, height: 40)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            ingredient.selected.toggle()
        }
        .padding(.vertical, 4)
    }
}

struct EnrichedIngredientsView_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State private var ingredients = [
                RecognizedIngredientWithDetails(
                    name: "Tomatoes",
                    edamamFoodId: "food_a6k79rrahp8fe2b26zussa3wtkqh",
                    category: "Vegetable",
                    imageURL: "https://www.edamam.com/food-img/23e/23e727a14f2b9f0d275d47a70d2b8d39.jpg",
                    quantityType: "Serving",
                    expirationDays: 7
                ),
                RecognizedIngredientWithDetails(
                    name: "Onions",
                    edamamFoodId: "food_bmrvi4ob4binw9a5m7l07amlfcoy",
                    category: "Vegetable",
                    imageURL: "https://www.edamam.com/food-img/205/205e6bf2399b85d34741892ef91cc603.jpg",
                    quantityType: "Serving",
                    expirationDays: 14
                )
            ]
            
            var body: some View {
                EnrichedIngredientsView(ingredients: $ingredients)
            }
        }
        
        return PreviewWrapper()
    }
} 