import SwiftUI
import AVFoundation
import Combine

struct IdentifiableTuple: Identifiable {
    let id = UUID()
    let item1: String
    let item2: String
    
    init(_ tuple: (String, String)) {
        self.item1 = tuple.0
        self.item2 = tuple.1
    }
}

struct HomeHeader: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        HStack {
            Text(userSession.fullName ?? "Chef")
                .font(.custom("Inter-Bold", size: 28))
                .lineLimit(1)
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
    @State private var scrollToTop = false
    @FocusState private var isSearchFieldFocused: Bool
    
    // Filter selections
    @State private var selectedCuisineType: String? = nil
    @State private var selectedDietType: String? = nil
    @State private var selectedHealthType: String? = nil
    @State private var selectedMealType: String? = nil
    @State private var selectedMaxTime: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            HomeHeader(showMenu: $showMenu)
                            
                            SearchComponent(
                                searchText: $searchText,
                                searchQuery: .constant("recipes"),
                                onSubmit: performSearch,
                                isSearchFieldFocused: _isSearchFieldFocused
                            )
                            
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
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Results")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            clearFilters()
                                        }) {
                                            Text("Clear All")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.secondary3)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    FilteredRecipesSection(filterController: filterController)
                                }
                            } else {
                                // Scrollable content
                                ScrollView {
                                    VStack(spacing: 20) {
                                        // Recipe Grids
                                        SimpleRecipeGrid(title: "From Pantry", recipes: homepageController.pantryRecipes)
                                        
                                        // Browse by Meal Type
                                        MealTypeSection(
                                            filterController: filterController,
                                            onSelectMealType: selectMealType
                                        )
                                        
                                        // Browse by Cuisine
                                        CuisineSection(
                                            filterController: filterController,
                                            onSelectCuisine: selectCuisine
                                        )
                                        
                                        SimpleRecipeGrid(title: "Featured", recipes: homepageController.featuredRecipes)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .id("top")
                    }
                    .blur(radius: showMenu || showFilters ? 5 : 0)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .onChange(of: scrollToTop) { newValue in
                        if newValue {
                            withAnimation(.smooth) {
                                scrollProxy.scrollTo("top", anchor: .top)
                            }
                            scrollToTop = false
                        }
                    }
                }
                
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
                        SideMenuView(userName: userSession.fullName ?? "Chef") {
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDisplayNameChanged"))) { notification in
                if let displayName = notification.userInfo?["displayName"] as? String {
                    userSession.updateFullName(displayName)
                }
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
        
        // Scroll to top when filters are applied
        scrollToTop = true
    }
    
    private func selectMealType(_ mealType: String) {
        // Reset other filters
        selectedCuisineType = nil
        selectedDietType = nil
        selectedHealthType = nil
        selectedMaxTime = nil
        
        // Set meal type filter
        selectedMealType = mealType
        
        // Apply filters
        applyFilters()
    }
    
    private func selectCuisine(_ cuisine: String) {
        // Reset other filters
        selectedMealType = nil
        selectedDietType = nil
        selectedHealthType = nil
        selectedMaxTime = nil
        
        // Set cuisine type filter
        selectedCuisineType = cuisine
        
        // Apply filters
        applyFilters()
    }
    
    private func clearFilters() {
        // Reset all selections
        selectedCuisineType = nil
        selectedMealType = nil
        selectedDietType = nil
        selectedHealthType = nil
        selectedMaxTime = nil
        
        // Clear search text
        searchText = ""
        
        // Reset controller filters
        filterController.resetFilters()
    }
    
    private func performSearch(_ query: String) {
        // Reset all filter selections
        selectedCuisineType = nil
        selectedMealType = nil
        selectedDietType = nil
        selectedHealthType = nil
        selectedMaxTime = nil
        
        // Reset controller filters
        filterController.resetFilters()
        
        // Set up a general search
        filterController.filters.searchQuery = query
        
        // Apply the search filter
        filterController.applyFilters()
    }
}
