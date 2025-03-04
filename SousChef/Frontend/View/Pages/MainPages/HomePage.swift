import SwiftUI

struct HomePage: View {

    @EnvironmentObject var userSession: UserSession
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showMenu = false

    let categories = ["Mexican", "French", "Italian", "American", "Greek", "Chinese", "Indian", "Middle Eastern", "Thai"]

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Chef John Paul Gaultier")
                            .font(.custom("Inter-Bold", size: 28))
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: {
                                // Notifications action
                            }) {
                                Image(systemName: "bell")
                                    .foregroundColor(.black)
                                    .overlay(
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: 6, y: -6)
                                    )
                            }
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.horizontal)

                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = (selectedCategory == category) ? nil : category
                                }) {
                                    Text(category)
                                        .font(.custom("Inter-Bold", size: 15))
                                        .foregroundColor(selectedCategory == category ? .white : .black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                        .background(selectedCategory == category ? AppColors.secondary3 : AppColors.lightGray)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    RecipeGrid(title: "Featured")
                    RecipeGrid(title: "Seasonal")
                    RecipeGrid(title: "Chicken")
                }
                .padding(.top, 20)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .blur(radius: showMenu ? 5 : 0)

            // Persistent menu container
            ZStack {
                // Background overlay
                if showMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showMenu = false
                            }
                        }
                        .transition(.opacity)
                }

                HStack {
                    Spacer()
                    SideMenuView(userName: "John Paul Gaultier") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showMenu = false
                        }
                    }
                    .frame(width: 250)
                    .frame(maxHeight: .infinity)
                    .background(Color.clear)
                    .offset(x: showMenu ? 0 : 300) // 300 matches or exceeds width
                }
            }
            .animation(.easeOut(duration: 0.3), value: showMenu)
            .zIndex(1)
        }
    }
}
