//
//  RecipeDetailView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 3/3/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: EdamamRecipeModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Recipe Image
                if let imageUrl = URL(string: recipe.image) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                }

                // Title
                Text(recipe.label)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Calories
                if let calories = recipe.totalNutrients.energy?.quantity {
                    Text("Calories: \(Int(calories)) kcal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // Ingredients
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                ForEach(recipe.ingredients, id: \.foodId) { ingredient in
                    Text("• \(ingredient.text)")
                        .padding(.horizontal)
                }


                // Nutrients
                Text("Nutritional Info")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 5) {
                    if let fat = recipe.totalNutrients.fat {
                        Text("Fat: \(String(format: "%.1f", fat.quantity)) \(fat.unit)")
                    }
                    if let protein = recipe.totalNutrients.protein {
                        Text("Protein: \(String(format: "%.1f", protein.quantity)) \(protein.unit)")
                    }
                    if let carbs = recipe.totalNutrients.carbs {
                        Text("Carbs: \(String(format: "%.1f", carbs.quantity)) \(carbs.unit)")
                    }
                    if let sugar = recipe.totalNutrients.sugar {
                        Text("Sugar: \(String(format: "%.1f", sugar.quantity)) \(sugar.unit)")
                    }
                    if let fiber = recipe.totalNutrients.fiber {
                        Text("Fiber: \(String(format: "%.1f", fiber.quantity)) \(fiber.unit)")
                    }
                    if let sodium = recipe.totalNutrients.sodium {
                        Text("Sodium: \(String(format: "%.1f", sodium.quantity)) \(sodium.unit)")
                    }
                }
                .padding(.horizontal)

                // Source Link
                if let url = URL(string: recipe.url) {
                    Link(destination: url) {
                        Text("View Full Recipe")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary2)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top)
        }
        .background(AppColors.background.edgesIgnoringSafeArea(.all))
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(
            recipe: EdamamRecipeModel(
                label: "Sample Recipe",
                image: "https://via.placeholder.com/300",
                url: "https://www.example.com",
                ingredients: [
                    EdamamRecipeIngredient(
                        text: "1 cup of sugar",
                        quantity: 1.0,
                        measure: "cup",
                        food: "sugar",
                        weight: 200.0,
                        foodCategory: "sugars",
                        foodId: "food_sugar",
                        image: nil
                    ),
                    EdamamRecipeIngredient(
                        text: "2 eggs",
                        quantity: 2.0,
                        measure: "unit",
                        food: "eggs",
                        weight: 100.0,
                        foodCategory: "Eggs",
                        foodId: "food_eggs",
                        image: nil
                    )
                ],
                totalNutrients: EdamamRecipeNutrients(
                    energy: EdamamRecipeNutrient(label: "Energy", quantity: 500, unit: "kcal"),
                    fat: EdamamRecipeNutrient(label: "Fat", quantity: 20, unit: "g"),
                    saturatedFat: nil,
                    transFat: nil,
                    carbs: EdamamRecipeNutrient(label: "Carbs", quantity: 60, unit: "g"),
                    fiber: EdamamRecipeNutrient(label: "Fiber", quantity: 5, unit: "g"),
                    sugar: EdamamRecipeNutrient(label: "Sugar", quantity: 30, unit: "g"),
                    protein: EdamamRecipeNutrient(label: "Protein", quantity: 10, unit: "g"),
                    cholesterol: EdamamRecipeNutrient(label: "Cholesterol", quantity: 100, unit: "mg"),
                    sodium: EdamamRecipeNutrient(label: "Sodium", quantity: 300, unit: "mg"),
                    calcium: nil,
                    potassium: nil,
                    iron: nil,
                    vitaminD: nil
                ),
                calories: 500,
                totalWeight: 200,
                cuisineType: ["american"],
                mealType: ["breakfast"],
                dishType: ["main course"]
            )
        )
    }
}

