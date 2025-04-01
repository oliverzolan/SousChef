import SwiftUI

struct ShoppingListsPage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var isShowingAddPopup = false
    @State private var newListName = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(userSession.shoppingLists) { list in
                        NavigationLink(destination: ShoppingCartPage(shoppingList: list)) {
                            Text(list.name)
                        }
                    }
                    .onDelete(perform: deleteLists)
                }
                .navigationTitle("Shopping Lists")
            }
            
            VStack {
                Spacer()
                Button(action: {
                    isShowingAddPopup = true
                }) {
                    Text("Create Shopping List")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColors.primary2)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            }
            
            if isShowingAddPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isShowingAddPopup = false
                    }
                
                VStack(spacing: 20) {
                    Text("New Shopping List")
                        .font(.headline)
                    TextField("Enter list name", text: $newListName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    HStack {
                        Button("Cancel") {
                            isShowingAddPopup = false
                            newListName = ""
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Add") {
                            let trimmedName = newListName.trimmingCharacters(in: .whitespaces)
                            guard !trimmedName.isEmpty else { return }
                            let newList = ShoppingList(name: trimmedName)
                            userSession.shoppingLists.append(newList)
                            newListName = ""
                            isShowingAddPopup = false
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        userSession.shoppingLists.remove(atOffsets: offsets)
    }
}

struct ShoppingListsPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.shoppingLists = [
            ShoppingList(name: "Weekly Groceries", items: [
                CartItem(name: "Tomatoes", price: 1.99, quantity: 2)
            ]),
            ShoppingList(name: "Party Supplies")
        ]
        
        return ShoppingListsPage()
            .environmentObject(mockSession)
    }
}
