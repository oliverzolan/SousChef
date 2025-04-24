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
                headerView

                if shoppingList.items.isEmpty {
                    Spacer()
                    Text("Your shopping cart is empty.")
                        .foregroundColor(.gray)
                        .font(.headline)
                    Spacer()
                } else {
                    List {
                        ForEach(shoppingList.items) { item in
                            SimpleCartItemRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                                            shoppingList.items.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                }

                totalsAndActionsView
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingAddIngredientPopup) {
                AddIngredientPopupShoppingCart(items: $shoppingList.items, scannedIngredient: nil, userSession: userSession)
            }
            .sheet(item: $itemToEdit) { item in
                EditItemPopup(item: item,
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
                              })
            }
            .toolbar { }
        }
        .background(Color.white)
    }
    
    private var headerView: some View {
        HStack {
            Text("\(shoppingList.name) List")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
        }
        .padding([.top, .horizontal])
    }
    
    private var totalsAndActionsView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total Items")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Spacer()
                Text("\(shoppingList.items.count)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
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
}

struct SimpleCartItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 8) {
            Text(item.name)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.85))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppColors.secondary3)
        .cornerRadius(8)
    }
}

struct ShoppingCartPage_Previews: PreviewProvider {
    static var previews: some View {
        let sampleList = ShoppingList(name: "Trader Joe's")
        sampleList.items = [
            CartItem(id: UUID(), name: "Egg", price: 0.0, quantity: 12)
        ]
        let session = UserSession()
        session.shoppingLists.append(sampleList)
        return ShoppingCartPage(shoppingList: sampleList)
            .environmentObject(session)
    }
}
