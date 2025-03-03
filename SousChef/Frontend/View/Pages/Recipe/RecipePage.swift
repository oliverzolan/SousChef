//
//  RecipeDetailView.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 3/3/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeModel

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
                if let calories = recipe.totalNutrients["ENERC_KCAL"]?.quantity {
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

                ForEach(recipe.ingredientLines, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .padding(.horizontal)
                }

                // Nutrients
                Text("Nutritional Info")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 5) {
                    if let fat = recipe.totalNutrients["FAT"] {
                        Text("Fat: \(String(format: "%.1f", fat.quantity)) \(fat.unit)")
                    }
                    if let protein = recipe.totalNutrients["PROCNT"] {
                        Text("Protein: \(String(format: "%.1f", protein.quantity)) \(protein.unit)")
                    }
                    if let carbs = recipe.totalNutrients["CHOCDF"] {
                        Text("Carbs: \(String(format: "%.1f", carbs.quantity)) \(carbs.unit)")
                    }
                    if let sugar = recipe.totalNutrients["SUGAR"] {
                        Text("Sugar: \(String(format: "%.1f", sugar.quantity)) \(sugar.unit)")
                    }
                    if let fiber = recipe.totalNutrients["FIBTG"] {
                        Text("Fiber: \(String(format: "%.1f", fiber.quantity)) \(fiber.unit)")
                    }
                    if let sodium = recipe.totalNutrients["NA"] {
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
            recipe: RecipeModel(
                uri: "sample_uri",
                label: "Sample Recipe",
                image: "https://via.placeholder.com/300",
                url: "https://www.example.com",
                source: "Sample Source",
                shareAs: "https://www.example.com/share",
                yield: 4,
                dietLabels: ["Low-Carb"],
                healthLabels: ["Vegan", "Gluten-Free"],
                cautions: ["Sulfites"],
                ingredientLines: [
                    "1 cup of sugar",
                    "2 eggs"
                ],
                ingredients: [],
                calories: 500,
                totalWeight: 200,
                totalTime: 30,
                cuisineType: ["american"],
                mealType: ["breakfast"],
                dishType: ["main course"],
                totalNutrients: [
                    "ENERC_KCAL": Nutrients(label: "Energy", quantity: 500, unit: "kcal"),
                    "FAT": Nutrients(label: "Fat", quantity: 20, unit: "g"),
                    "CHOCDF": Nutrients(label: "Carbs", quantity: 60, unit: "g"),
                    "FIBTG": Nutrients(label: "Fiber", quantity: 5, unit: "g"),
                    "SUGAR": Nutrients(label: "Sugar", quantity: 30, unit: "g"),
                    "PROCNT": Nutrients(label: "Protein", quantity: 10, unit: "g"),
                    "NA": Nutrients(label: "Sodium", quantity: 300, unit: "mg")
                ]
            )
        )
    }
}
