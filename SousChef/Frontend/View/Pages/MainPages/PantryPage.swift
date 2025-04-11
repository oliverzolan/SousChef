//
//  pantryPage.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/5/25.
//

import SwiftUI

struct PantryPage: View {
    @StateObject private var pantryController: PantryController
    @EnvironmentObject var userSession: UserSession
    @State private var searchText: String = ""
    @State private var searchQuery: String = "ingredients"
    @State private var showAddIngredientSheet = false
    @State private var isSearchActive = false
    @FocusState private var isSearchFieldFocused: Bool

    init(userSession: UserSession) {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Your Pantry")
                            .font(.system(size: 28, weight: .bold))
                        
                        Spacer()
                        
                        // Add ingredients button
                        Button(action: {
                            showAddIngredientSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Search ingredients...", text: $searchText)
                            .font(.system(size: 16))
                            .padding(10)
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                isSearchFieldFocused = false
                            }
                        
                        if !searchText.isEmpty || isSearchFieldFocused {
                            Button(action: {
                                searchText = ""
                                isSearchFieldFocused = false
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
                .padding(.bottom, 10)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)

                // Loading indicator
                if pantryController.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Loading your ingredients...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                    Spacer()
                } else if isSearchFieldFocused {
                    // Search results view
                    VStack {
                        Text("Type to search ingredients...")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        Spacer()
                    }
                } else {
                    // Main content
                    GeometryReader { geo in
                        let availableHeight = geo.size.height
                        let screenWidth = geo.size.width
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 20) {
                                HStack(spacing: 10) {
                                    // Left column
                                    VStack(spacing: 20) {
                                        NavigationLink(destination: VegetablesIngredientsPage()) {
                                            CategoryButton(imageName: "vegetablesButton", fillMode: .fill)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)

                                        NavigationLink(destination: GrainsIngredientsPage()) {
                                            CategoryButton(imageName: "grainsButton", fillMode: .fill)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.20)

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

                                        NavigationLink(destination: DrinksIngredientsPage()) {
                                            CategoryButton(imageName: "drinksButton", fillMode: .fill)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: availableHeight * 0.16)
                                    }
                                    .frame(maxWidth: .infinity)

                                    // Right column
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

                                // Bottom row with 60/40 split
                                HStack(spacing: 10) {
                                    NavigationLink(destination: CondimentsIngredientsPage()) {
                                        CategoryButton(imageName: "condimentsButton", fillMode: .fill)
                                    }
                                    .frame(width: screenWidth * 0.6 - 16)

                                    NavigationLink(destination: AllIngredientsPage(userSession: userSession)) {
                                        CategoryButton(imageName: "allButton", fillMode: .fill)
                                    }
                                    .frame(width: screenWidth * 0.4 - 16)
                                }
                                .frame(height: availableHeight * 0.12)
                            }
                            .padding(8)
                        }
                        .scrollDisabled(true)
                    }
                }
            }
            .background(Color(.systemGray6).opacity(0.5))
            .onAppear {
                pantryController.fetchIngredients()
            }
            .onChange(of: isSearchFieldFocused) { isFocused in
                isSearchActive = isFocused
            }
            .sheet(isPresented: $showAddIngredientSheet) {
                AddIngredientPopup(ingredients: .constant([]), scannedIngredient: nil, userSession: userSession)
            }
        }
        .navigationBarHidden(true)
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
