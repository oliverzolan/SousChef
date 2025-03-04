import SwiftUICore

struct FruitsIngredientsPage: View {
    var body: some View {
        BaseIngredientsPage(
            title: "Fruits",
            ingredients: ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"]
        )
    }
}

