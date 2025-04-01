//
//  FilterView.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct FilterCategoryButton: View {
    let category: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isActive ? AppColors.secondary1 : Color.gray.opacity(0.1))
                .foregroundColor(isActive ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct FilterOptionsView: View {
    @ObservedObject var filterController: FilterController
    let category: String
    @Binding var showFilter: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Filter by \(category)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showFilter = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 8)
            
            ScrollView {
                switch category {
                case "Cuisine":
                    cuisineOptions
                case "Meal":
                    mealOptions
                case "Diet":
                    dietOptions
                case "Health":
                    healthOptions
                case "Time":
                    timeOptions
                default:
                    EmptyView()
                }
            }
            
            HStack {
                Button(action: {
                    resetCurrentFilter()
                    showFilter = false
                }) {
                    Text("Clear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    filterController.applyFilters()
                    showFilter = false
                }) {
                    Text("Apply")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primary1)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 16)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var cuisineOptions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
            ForEach(FilterModel.cuisineTypes, id: \.self) { cuisine in
                filterOption(
                    title: cuisine,
                    isSelected: filterController.filters.cuisineType == cuisine
                ) {
                    filterController.filters.cuisineType = (filterController.filters.cuisineType == cuisine) ? nil : cuisine
                }
            }
        }
    }
    
    private var mealOptions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
            ForEach(FilterModel.mealTypes, id: \.self) { meal in
                filterOption(
                    title: meal,
                    isSelected: filterController.filters.mealType == meal
                ) {
                    filterController.filters.mealType = (filterController.filters.mealType == meal) ? nil : meal
                }
            }
        }
    }
    
    private var dietOptions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
            ForEach(FilterModel.dietTypes, id: \.self) { diet in
                filterOption(
                    title: diet,
                    isSelected: filterController.filters.dietType == diet
                ) {
                    filterController.filters.dietType = (filterController.filters.dietType == diet) ? nil : diet
                }
            }
        }
    }
    
    private var healthOptions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
            ForEach(FilterModel.healthTypes, id: \.self) { health in
                filterOption(
                    title: health,
                    isSelected: filterController.filters.healthType == health
                ) {
                    filterController.filters.healthType = (filterController.filters.healthType == health) ? nil : health
                }
            }
        }
    }
    
    private var timeOptions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
            ForEach(FilterModel.cookTimes, id: \.self) { time in
                filterOption(
                    title: "< \(time) min",
                    isSelected: filterController.filters.maxTime == time
                ) {
                    filterController.filters.maxTime = (filterController.filters.maxTime == time) ? nil : time
                }
            }
        }
    }
    
    private func filterOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? AppColors.primary1 : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? AppColors.primary1 : Color.clear, lineWidth: 1)
                )
        }
    }
    
    private func resetCurrentFilter() {
        switch category {
        case "Cuisine":
            filterController.filters.cuisineType = nil
        case "Meal":
            filterController.filters.mealType = nil
        case "Diet":
            filterController.filters.dietType = nil
        case "Health":
            filterController.filters.healthType = nil
        case "Time":
            filterController.filters.maxTime = nil
        default:
            break
        }
    }
}

struct FilterCategoriesBar: View {
    @ObservedObject var filterController: FilterController
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: {
                    filterController.resetFilters()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                        Text("Clear All")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.black)
                    .cornerRadius(20)
                }
                .opacity(filterController.filters.isEmpty ? 0.4 : 1)
                .disabled(filterController.filters.isEmpty)
                
                ForEach(FilterModel.categories, id: \.self) { category in
                    FilterCategoryButton(
                        category: category,
                        isActive: filterController.filters.isCategoryActive(category),
                        action: {
                            selectedCategory = category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
} 
