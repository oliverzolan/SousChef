import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var userSession: UserSession
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var recipes: [RecipeModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showMenu = false

    let categories = ["Mexican", "French", "Italian", "American", "Greek", "Chinese", "Indian", "Middle Eastern", "Thai"]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        searchBar
                        categoryScroll
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else if !recipes.isEmpty {
                            recipeGrid
                        } else {
                            Text("Search for recipes to get started!")
                                .foregroundColor(.gray)
                                .padding()
                        }
                        
                        RecipeGrid(title: "Featured")
                        RecipeGrid(title: "Seasonal")
                        RecipeGrid(title: "Chicken")
                    }
                    .padding(.top)
                }
                .blur(radius: showMenu ? 5 : 0)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                if showMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showMenu = false
                            }
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
                        .offset(x: showMenu ? 0 : 300)
                    }
                    .animation(.easeOut(duration: 0.3), value: showMenu)
                    .zIndex(1)
                }
            }
            .onChange(of: searchText) { _ in
                fetchRecipes()
            }
        }
    }

    var header: some View {
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
    }

    var searchBar: some View {
        TextField("Search", text: $searchText)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
    }

    var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = (selectedCategory == category) ? nil : category
                        searchText = category
                        fetchRecipes()
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
    }

    var recipeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(recipes, id: \.url) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeBoxView(recipe: recipe)
                }
            }
        }
        .padding(.horizontal)
    }

    func fetchRecipes() {
        guard !searchText.isEmpty else {
            recipes = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let api = RecipeAPI()
        api.search(query: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipeResponse):
                    self.recipes = recipeResponse.hits.map { $0.recipe } 
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

