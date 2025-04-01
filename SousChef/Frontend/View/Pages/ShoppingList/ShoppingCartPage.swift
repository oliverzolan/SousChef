import SwiftUI

struct ShoppingCartPage: View {
    @ObservedObject var shoppingList: ShoppingList
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingAddIngredientPopup = false

    var body: some View {
        NavigationView {
            VStack {
                // Header with Shopping List name.
                HStack {
                    Text("Shopping Cart: \(shoppingList.name)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                // List of items.
                if shoppingList.items.isEmpty {
                    Spacer()
                    Text("Your shopping cart is empty.")
                        .foregroundColor(.gray)
                        .font(.headline)
                    Spacer()
                } else {
                    List {
                        ForEach(shoppingList.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("Price: $\(item.price, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack {
                                    Text("Qty: \(item.quantity)")
                                        .font(.subheadline)
                                    Text("$\(Double(item.quantity) * item.price, specifier: "%.2f")")
                                        .font(.subheadline)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Total")
                            .font(.title2)
                            .fontWeight(.medium)
                        Spacer()
                        Text("$\(shoppingList.total(), specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Button(action: {
                        isShowingAddIngredientPopup = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Ingredient")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary2)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingAddIngredientPopup) {
                AddIngredientPopupShoppingCart(items: $shoppingList.items, scannedIngredient: nil, userSession: userSession)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        shoppingList.items.remove(atOffsets: offsets)
    }
}

struct ShoppingCartPage_Previews: PreviewProvider {
    static var previews: some View {
        let sampleList = ShoppingList(name: "Weekly Groceries")
        sampleList.items = [
            CartItem(name: "Tomatoes", price: 1.99, quantity: 2),
            CartItem(name: "Basil", price: 0.99, quantity: 1)
        ]
        let session = UserSession()
        session.shoppingLists.append(sampleList)
        return ShoppingCartPage(shoppingList: sampleList)
            .environmentObject(session)
    }
}
