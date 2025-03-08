import SwiftUI

struct NutritionFactsPopup: View {
    let ingredient: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Nutrition Facts")
                .font(.title2)
                .bold()
            Text("Details for \(ingredient)")
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}

struct NutritionFactsPopup_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsPopup(ingredient: "Carrots")
    }
}



//struct NutritionFactsPopup: View {
//    let ingredient: String
//    // Example static nutrition values for demonstration.
//    let servingSize: String = "1 cup"
//    let servingsPerContainer: String = "2"
//    let calories: String = "150"
//    let totalFat: String = "5g"
//    let saturatedFat: String = "1g"
//    let cholesterol: String = "0mg"
//    let sodium: String = "150mg"
//    let totalCarbohydrate: String = "20g"
//    let dietaryFiber: String = "3g"
//    let sugars: String = "10g"
//    let protein: String = "4g"
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 0) {
//                // Header
//                Text("Nutrition Facts")
//                    .font(.system(size: 28, weight: .heavy))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 10)
//                    .background(Color.black)
//                    .foregroundColor(.white)
//                
//                // Serving Info
//                VStack(alignment: .leading, spacing: 2) {
//                    HStack {
//                        Text("Serving Size")
//                        Spacer()
//                        Text(servingSize)
//                    }
//                    HStack {
//                        Text("Servings Per Container")
//                        Spacer()
//                        Text(servingsPerContainer)
//                    }
//                }
//                .font(.system(size: 14, weight: .bold))
//                .padding(8)
//                .overlay(Rectangle().frame(height: 2).foregroundColor(.black), alignment: .bottom)
//                .padding(.horizontal, 4)
//                
//                // Calories
//                HStack {
//                    Text("Calories")
//                        .font(.system(size: 18, weight: .bold))
//                    Spacer()
//                    Text(calories)
//                        .font(.system(size: 18, weight: .bold))
//                }
//                .padding(8)
//                .overlay(Rectangle().frame(height: 2).foregroundColor(.black), alignment: .bottom)
//                .padding(.horizontal, 4)
//                
//                // % Daily Value header
//                HStack {
//                    Text("% Daily Value*")
//                        .font(.system(size: 12, weight: .bold))
//                    Spacer()
//                }
//                .padding(.horizontal, 4)
//                .padding(.top, 4)
//                
//                // Nutrients
//                VStack(spacing: 0) {
//                    nutrientRow(nutrient: "Total Fat", value: totalFat, dailyValue: "8%")
//                    nutrientRow(nutrient: "Saturated Fat", value: saturatedFat, dailyValue: "5%")
//                    nutrientRow(nutrient: "Cholesterol", value: cholesterol, dailyValue: "0%")
//                    nutrientRow(nutrient: "Sodium", value: sodium, dailyValue: "6%")
//                    nutrientRow(nutrient: "Total Carbohydrate", value: totalCarbohydrate, dailyValue: "10%")
//                    nutrientRow(nutrient: "Dietary Fiber", value: dietaryFiber, dailyValue: "12%")
//                    nutrientRow(nutrient: "Sugars", value: sugars, dailyValue: "")
//                    nutrientRow(nutrient: "Protein", value: protein, dailyValue: "")
//                }
//                .font(.system(size: 12))
//                .padding(.horizontal, 4)
//                .padding(.vertical, 4)
//                
//                // Footnote
//                Text("* Percent Daily Values are based on a 2,000 calorie diet.")
//                    .font(.system(size: 10))
//                    .multilineTextAlignment(.center)
//                    .padding(8)
//            }
//            .border(Color.black, width: 4)
//            .padding()
//        }
//    }
//    
//    // Helper view for a nutrient row.
//    @ViewBuilder
//    private func nutrientRow(nutrient: String, value: String, dailyValue: String) -> some View {
//        HStack {
//            Text(nutrient)
//                .fontWeight(nutrient == "Total Fat" || nutrient == "Total Carbohydrate" ? .bold : .regular)
//            Spacer()
//            Text(value)
//            if !dailyValue.isEmpty {
//                Spacer()
//                Text(dailyValue)
//            }
//        }
//        .padding(4)
//        .overlay(Rectangle().frame(height: 1).foregroundColor(.black), alignment: .bottom)
//    }
//}
