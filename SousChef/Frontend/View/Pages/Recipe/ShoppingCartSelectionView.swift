import SwiftUI

struct ShoppingCartSelectionView: View {
    @EnvironmentObject var userSession: UserSession
    var onSelect: (ShoppingList) -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            if userSession.shoppingLists.isEmpty {
                VStack(spacing: 20) {
                    Text("No shopping lists available.")
                        .font(.headline)
                    Text("Please create a shopping list from the Shopping Lists page.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .navigationTitle("Select Shopping Cart")
            } else {
                List(userSession.shoppingLists) { list in
                    Button(action: {
                        onSelect(list)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(list.name)
                    }
                }
                .navigationTitle("Select Shopping Cart")
                .navigationBarItems(trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}
