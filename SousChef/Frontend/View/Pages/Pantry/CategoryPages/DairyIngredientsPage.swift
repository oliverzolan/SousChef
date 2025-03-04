import SwiftUICore

struct DairyIngredientsPage: View {
    var body: some View {
        BaseIngredientsPage(
            title: "Dairy",
            ingredients: ["Milk", "Cheddar Cheese", "Greek Yogurt"]
        )
    }
}

