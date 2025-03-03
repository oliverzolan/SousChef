import SwiftUICore

struct VegetablesIngredientsPage: View {
    var body: some View {
        BaseIngredientsPage(
            title: "Vegetables",
            ingredients: ["Carrots", "Broccoli", "Spinach"]
        )
    }
}
