//
//  pantryPage.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/5/25.
//

import SwiftUI

struct PantryPage: View {
    @StateObject private var pantryController: PantryController
    @StateObject private var ingredientController: IngredientController
    @EnvironmentObject var userSession: UserSession
    @State private var searchText: String = ""
    @State private var searchQuery: String = "ingredients"
    @State private var showAddIngredientSheet = false
    @State private var isSearchActive = false
    @State private var showSearchResults = false
    @FocusState private var isSearchFieldFocused: Bool

    init(userSession: UserSession) {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
        _ingredientController = StateObject(wrappedValue: IngredientController(userSession: userSession))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                if pantryController.isLoading {
                    loadingView
                } else {
                    mainContentView
                }
            }
            .background(Color(.systemGray6).opacity(0.5))
            .onAppear {
                pantryController.fetchIngredients()
                
                // Reset search state when appearing
                searchText = ""
                showSearchResults = false 
                isSearchActive = false
            }
            .onChange(of: isSearchFieldFocused) { isFocused in
                isSearchActive = isFocused
            }
            .sheet(isPresented: $showAddIngredientSheet) {
                AddIngredientPopup()
                    .environmentObject(userSession)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - UI Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Pantry")
                    .font(.system(size: 28, weight: .bold))
                
                Spacer()
                
                Button(action: { showAddIngredientSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            searchBarView
        }
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            NavigationLink(
                destination: PantrySearchPage(searchQuery: searchText, userSession: userSession),
                isActive: $showSearchResults
            ) {
                EmptyView()
            }
            
            TextField("Search your pantry...", text: $searchText)
                .font(.system(size: 16))
                .padding(10)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    if !searchText.isEmpty {
                        showSearchResults = true
                        isSearchFieldFocused = false
                    }
                }
            
            if !searchText.isEmpty || isSearchFieldFocused {
                Button(action: {
                    searchText = ""
                    isSearchFieldFocused = false
                    showSearchResults = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading your ingredients...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 16)
            Spacer()
        }
    }
    
    private var searchResultsView: some View {
        VStack {
            if ingredientController.isLoading {
                ProgressView("Searching...")
                    .padding(.top, 30)
            } else if let errorMessage = ingredientController.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 30)
            } else if ingredientController.searchResults.isEmpty {
                Text("No ingredients found")
                    .foregroundColor(.gray)
                    .padding(.top, 30)
            } else {
                // We don't need this view anymore since we're using the PantrySearchPage
                Text("Navigating to search results...")
                    .foregroundColor(.gray)
                    .padding(.top, 30)
            }
        }
    }
    
    private var mainContentView: some View {
        GeometryReader { geo in
            let availableHeight = geo.size.height
            let screenWidth = geo.size.width
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    categoryGrid(availableHeight: availableHeight, screenWidth: screenWidth)
                }
                .padding(8)
            }
            .scrollDisabled(true)
        }
    }
    
    private func categoryGrid(availableHeight: CGFloat, screenWidth: CGFloat) -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                leftColumn(availableHeight: availableHeight)
                rightColumn(availableHeight: availableHeight)
            }
            
            bottomRow(screenWidth: screenWidth, availableHeight: availableHeight)
        }
    }
    
    private func leftColumn(availableHeight: CGFloat) -> some View {
        VStack(spacing: 20) {
            NavigationLink(destination: VegetablesIngredientsPage()) {
                CategoryButton(imageName: "vegetablesButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)

            NavigationLink(destination: GrainsIngredientsPage()) {
                CategoryButton(imageName: "grainsButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)

            spicesAndCannedRow(availableHeight: availableHeight)

            NavigationLink(destination: DrinksIngredientsPage()) {
                CategoryButton(imageName: "drinksButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.16)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func spicesAndCannedRow(availableHeight: CGFloat) -> some View {
        HStack(spacing: 10) {
            NavigationLink(destination: SpicesIngredientsPage()) {
                CategoryButton(imageName: "spicesButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.14)

            NavigationLink(destination: CannedIngredientsPage()) {
                CategoryButton(imageName: "cannedButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.14)
        }
    }
    
    private func rightColumn(availableHeight: CGFloat) -> some View {
        VStack(spacing: 37) {
            NavigationLink(destination: MeatsIngredientsPage()) {
                CategoryButton(imageName: "meatsButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)

            NavigationLink(destination: FruitsIngredientsPage()) {
                CategoryButton(imageName: "fruitButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.30)

            NavigationLink(destination: DairyIngredientsPage()) {
                CategoryButton(imageName: "dairyButton", fillMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func bottomRow(screenWidth: CGFloat, availableHeight: CGFloat) -> some View {
        HStack(spacing: 10) {
            NavigationLink(destination: CondimentsIngredientsPage()) {
                CategoryButton(imageName: "condimentsButton", fillMode: .fill)
            }
            .frame(width: screenWidth * 0.6 - 16)

            NavigationLink(destination: AllIngredientsPage()) {
                CategoryButton(imageName: "allButton", fillMode: .fill)
            }
            .frame(width: screenWidth * 0.4 - 16)
        }
        .frame(height: availableHeight * 0.12)
    }
    
    // MARK: - Helper Functions
    
    private func addIngredientToPantry(_ ingredient: AWSIngredientModel) {
        ingredientController.addIngredientToDatabase(ingredient) {
            // After successfully adding, refresh the pantry items
            pantryController.fetchIngredients()
            
            // Show a toast or notification here if needed
            // For now, just reset the search
            searchText = ""
            showSearchResults = false
        }
    }
}

struct CategoryButton: View {
    var imageName: String
    var fillMode: ContentMode = .fill
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    imageView
                }
            } else {
                imageView
            }
        }
    }
    
    private var imageView: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: fillMode)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 3)
    }
}

struct PantryPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.token = "mock_token"

        return PantryPage(userSession: mockSession)
            .environmentObject(mockSession)
            .previewDevice("iPhone 16 Pro")
    }
}
