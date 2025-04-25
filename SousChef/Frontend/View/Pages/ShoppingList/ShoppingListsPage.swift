

import SwiftUI
struct ShoppingListsPage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var isShowingAddPopup = false
    @State private var newListName = ""
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy"
        return formatter
    }
    var body: some View {
        VStack(spacing: 0) {
            // Add header at the top
            ShoppingListHeader()
            ZStack {
                NavigationView {
                    List {
                        ForEach(userSession.shoppingLists) { list in
                            NavigationLink(destination: ShoppingCartPage(shoppingList: list)) {
                                HStack(spacing: 8) {
                                    Text(list.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Created \(dateFormatter.string(from: list.createdDate))")
                                        .font(.subheadline)
                                        .foregroundColor(Color.white.opacity(0.85))
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(AppColors.secondary3)
                        }
                        .onDelete(perform: deleteLists)
                    }
                    .scrollDisabled(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .accentColor(.white)
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
                                let newList = ShoppingList(name: trimmedName, items: [], createdDate: Date())
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
    }
    private func deleteLists(at offsets: IndexSet) {
        userSession.shoppingLists.remove(atOffsets: offsets)
    }
}
struct ShoppingListsPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.shoppingLists = [
            ShoppingList(name: "Walmart", createdDate: Date()),
            ShoppingList(name: "Target", createdDate: Date()),
            ShoppingList(name: "Trader Joe's", createdDate: Date())
        ]
        return ShoppingListsPage()
            .environmentObject(mockSession)
    }
}

