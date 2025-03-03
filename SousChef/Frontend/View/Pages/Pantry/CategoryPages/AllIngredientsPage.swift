import SwiftUICore

struct AllIngredientsPage: View {
    var body: some View {
        BaseIngredientsPage(
            title: "Ingredients",
            ingredients: ["Rice", "Quinoa", "Oats"]
        )
    }
}

