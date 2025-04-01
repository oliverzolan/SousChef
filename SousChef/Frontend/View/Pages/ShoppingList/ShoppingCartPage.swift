import SwiftUI

struct ShoppingCartPage: View {
    @ObservedObject var shoppingList: ShoppingList
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss

    @State private var isShowingAddIngredientPopup = false
    @State private var itemToEdit: CartItem?
    @State private var editedQuantity: String = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Shopping Cart: \(shoppingList.name)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.top, .horizontal])
                
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                                        shoppingList.items.remove(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    itemToEdit = item
                                    editedQuantity = String(item.quantity)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
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
                AddIngredientPopupShoppingCart(
                    items: $shoppingList.items,
                    scannedIngredient: nil,
                    userSession: userSession
                )
            }
            .sheet(item: $itemToEdit) { item in
                EditItemPopup(
                    item: item,
                    quantity: $editedQuantity,
                    onSave: { updatedQuantity in
                        if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }),
                           let qty = Int(updatedQuantity) {
                            shoppingList.items[index].quantity = qty
                        }
                        itemToEdit = nil
                    },
                    onDelete: {
                        if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                            shoppingList.items.remove(at: index)
                        }
                        itemToEdit = nil
                    }
                )
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
            CartItem(name: "Basil", price: 0.99, quantity: 1),
            CartItem(name: "Olive Oil", price: 3.49, quantity: 1)
        ]
        let session = UserSession()
        session.shoppingLists.append(sampleList)

        return ShoppingCartPage(shoppingList: sampleList)
            .environmentObject(session)
    }
}
