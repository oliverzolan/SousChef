import SwiftUICore

struct DrinksIngredientsPage: View {
    var body: some View {
        BaseIngredientsPage(
            title: "Drinks",
            ingredients: ["Beer", "Cider", "Wine", "Soda", "Lemonade", "Mocktail"]
        )
    }
}
