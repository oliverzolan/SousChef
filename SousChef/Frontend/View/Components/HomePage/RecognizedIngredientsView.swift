import SwiftUI

struct RecognizedIngredientsView: View {
    @Binding var ingredients: [RecognizedIngredient]
    @State private var searchText: String = ""
    
    var filteredIngredients: [RecognizedIngredient] {
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
                    
                    IngredientRow(ingredient: bindingIngredient)
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

struct IngredientRow: View {
    @Binding var ingredient: RecognizedIngredient
    
    var body: some View {
        HStack {
            Button(action: {
                ingredient.selected.toggle()
            }) {
                Image(systemName: ingredient.selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(ingredient.selected ? AppColors.primary1 : .gray)
            }
            
            Text(ingredient.name)
                .padding(.leading, 8)
                .foregroundColor(ingredient.selected ? .primary : .gray)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            ingredient.selected.toggle()
        }
        .padding(.vertical, 4)
    }
}

struct RecognizedIngredientsView_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State private var ingredients = [
                RecognizedIngredient(name: "Tomatoes"),
                RecognizedIngredient(name: "Onions"),
                RecognizedIngredient(name: "Garlic"),
                RecognizedIngredient(name: "Olive Oil")
            ]
            
            var body: some View {
                RecognizedIngredientsView(ingredients: $ingredients)
            }
        }
        
        return PreviewWrapper()
    }
} 