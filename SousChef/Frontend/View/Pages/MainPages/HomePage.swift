import SwiftUI
import AVFoundation

struct IdentifiableTuple: Identifiable {
    let id = UUID()
    let item1: String
    let item2: String
    
    init(_ tuple: (String, String)) {
        self.item1 = tuple.0
        self.item2 = tuple.1
    }
}

struct HomePage: View {
    @EnvironmentObject var homepageController: HomepageController
    @EnvironmentObject var userSession: UserSession
    @StateObject private var filterController = FilterController()
    
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showMenu = false
    @State private var showFilters = false
    @State private var navigateToFilteredResults = false
    @State private var filtersViewModel: FiltersViewModel?
    @State private var selectedFilterCategory: String? = nil
    
    // Filter selections
    @State private var selectedCuisineType: String? = nil
    @State private var selectedDietType: String? = nil
    @State private var selectedHealthType: String? = nil
    @State private var selectedMealType: String? = nil
    @State private var selectedMaxTime: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        HomeHeader(showMenu: $showMenu)
                        HomeSearchBar(searchText: $searchText)
                        HomeFilterBar(
                            selectedFilterCategory: $selectedFilterCategory,
                            showFilters: $showFilters,
                            selectedCuisineType: $selectedCuisineType,
                            selectedMealType: $selectedMealType,
                            selectedDietType: $selectedDietType,
                            selectedHealthType: $selectedHealthType,
                            selectedMaxTime: $selectedMaxTime,
                            filterController: filterController,
                            onApplyFilters: applyFilters
                        )
                        
                        if hasActiveFilters {
                            FilteredRecipesSection(filterController: filterController)
                        } else {
                            // Scrollable content
                            ScrollView {
                                VStack(spacing: 20) {
                                    // Recipe Grids
                                    SimpleRecipeGrid(title: "From Pantry", recipes: homepageController.pantryRecipes)
                                    SimpleRecipeGrid(title: "Featured", recipes: homepageController.featuredRecipes)
                                    
                                    // Browse by Cuisine
                                    CuisineSection()
                                    
                                    // Browse by Meal Type
                                    MealTypeSection()
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
                .blur(radius: showMenu || showFilters ? 5 : 0)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                if navigateToFilteredResults, 
                   let filters = filtersViewModel {
                    NavigationLink(
                        destination: FilteredRecipeListView(filters: filters),
                        isActive: $navigateToFilteredResults
                    ) {
                        EmptyView()
                    }
                }
                
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
                
                if showFilters {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showFilters = false
                                }
                            }
                        
                        VStack {
                            Spacer()
                            
                            FiltersView(
                                cuisineTypes: FilterModel.cuisineTypes,
                                mealTypes: FilterModel.mealTypes,
                                dietTypes: FilterModel.dietTypes,
                                healthTypes: FilterModel.healthTypes,
                                cookTimes: FilterModel.cookTimes,
                                selectedCuisineType: $selectedCuisineType,
                                selectedMealType: $selectedMealType,
                                selectedDietType: $selectedDietType,
                                selectedHealthType: $selectedHealthType,
                                selectedMaxTime: $selectedMaxTime,
                                onApply: {
                                    applyFilters()
                                },
                                onDismiss: {
                                    withAnimation(.spring()) {
                                        showFilters = false
                                    }
                                }
                            )
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
                            .padding(.horizontal)
                            .offset(y: showFilters ? 0 : UIScreen.main.bounds.height)
                        }
                        .animation(.spring(), value: showFilters)
                    }
                    .zIndex(2)
                }
            }
            .onAppear {
                // Reset filter category selection on appearing
                selectedFilterCategory = nil
                // Only load if needed to prevent reloading
                homepageController.fetchPantryRecipesIfNeeded()
            }
            .onDisappear {
                selectedFilterCategory = nil
                showFilters = false
            }
        }
    }

    var hasActiveFilters: Bool {
        selectedCuisineType != nil || 
        selectedMealType != nil || 
        selectedDietType != nil || 
        selectedHealthType != nil || 
        selectedMaxTime != nil ||
        !filterController.filters.isEmpty
    }
    
    private func applyFilters() {
        // Copy over selections to the FilterController
        filterController.filters.cuisineType = selectedCuisineType
        filterController.filters.mealType = selectedMealType
        filterController.filters.dietType = selectedDietType
        filterController.filters.healthType = selectedHealthType
        filterController.filters.maxTime = selectedMaxTime
        
        // Apply filters
        filterController.applyFilters()
        
        // Close filters panel if open
        withAnimation(.spring()) {
            showFilters = false
        }
    }
}
