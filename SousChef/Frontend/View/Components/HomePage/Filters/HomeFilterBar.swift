//
//  HomeFilterBar.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct HomeFilterBar: View {
    @Binding var selectedFilterCategory: String?
    @Binding var showFilters: Bool
    @Binding var selectedCuisineType: String?
    @Binding var selectedMealType: String?
    @Binding var selectedDietType: String?
    @Binding var selectedHealthType: String?
    @Binding var selectedMaxTime: Int?
    var filterController: FilterController
    var onApplyFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FilterModel.categories, id: \.self) { category in
                        Button(action: {
                            withAnimation {
                                if selectedFilterCategory == category {
                                    selectedFilterCategory = nil
                                    showFilters = false
                                } else {
                                    selectedFilterCategory = category
                                    showFilters = true
                                    
                                    // Set the tab based on selected category
                                    switch category {
                                    case "Cuisine": setSelectedFilterTab(0)
                                    case "Meal": setSelectedFilterTab(1)
                                    case "Diet": setSelectedFilterTab(2)
                                    case "Health": setSelectedFilterTab(3)
                                    case "Time": setSelectedFilterTab(4)
                                    default: setSelectedFilterTab(0)
                                    }
                                }
                            }
                        }) {
                            Text(category)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(isFilterCategoryActive(category) ? .white : .black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(isFilterCategoryActive(category) ? AppColors.secondary3 : Color.gray.opacity(0.15))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Active Filters
            if hasActiveFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedCuisineType = nil
                            selectedMealType = nil
                            selectedDietType = nil
                            selectedHealthType = nil
                            selectedMaxTime = nil
                            filterController.resetFilters()
                        }) {
                            HStack {
                                Text("Clear All")
                                Image(systemName: "xmark")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if let cuisine = selectedCuisineType {
                            FilterTag(text: cuisine, onRemove: { 
                                selectedCuisineType = nil
                                if hasActiveFilters {
                                    onApplyFilters()
                                }
                            })
                        }
                        
                        if let mealType = selectedMealType {
                            FilterTag(text: mealType, onRemove: { 
                                selectedMealType = nil
                                if hasActiveFilters {
                                    onApplyFilters()
                                }
                            })
                        }
                        
                        if let dietType = selectedDietType {
                            FilterTag(text: dietType, onRemove: { 
                                selectedDietType = nil
                                if hasActiveFilters {
                                    onApplyFilters()
                                }
                            })
                        }
                        
                        if let healthType = selectedHealthType {
                            FilterTag(text: healthType, onRemove: { 
                                selectedHealthType = nil
                                if hasActiveFilters {
                                    onApplyFilters()
                                }
                            })
                        }
                        
                        if let maxTime = selectedMaxTime {
                            FilterTag(text: "≤\(maxTime) min", onRemove: { 
                                selectedMaxTime = nil
                                if hasActiveFilters {
                                    onApplyFilters()
                                }
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Helper to set the selected filter tab
    private func setSelectedFilterTab(_ index: Int) {
        FiltersView.selectedTabStatic = index
    }
    
    var hasActiveFilters: Bool {
        selectedCuisineType != nil || 
        selectedMealType != nil || 
        selectedDietType != nil || 
        selectedHealthType != nil || 
        selectedMaxTime != nil ||
        !filterController.filters.isEmpty
    }
    
    private func isFilterCategoryActive(_ category: String) -> Bool {
        switch category {
        case "Cuisine":
            return selectedCuisineType != nil || filterController.filters.cuisineType != nil
        case "Meal":
            return selectedMealType != nil || filterController.filters.mealType != nil
        case "Diet":
            return selectedDietType != nil || filterController.filters.dietType != nil
        case "Health":
            return selectedHealthType != nil || filterController.filters.healthType != nil
        case "Time":
            return selectedMaxTime != nil || filterController.filters.maxTime != nil
        default:
            return false
        }
    }
}

// Component to display an active filter tag
struct FilterTag: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 14))
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
            }
        }
        .foregroundColor(.black)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
} 
