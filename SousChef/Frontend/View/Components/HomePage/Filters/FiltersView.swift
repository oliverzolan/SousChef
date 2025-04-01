//
//  FiltersView.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct FiltersView: View {
    // Static property to allow setting tab from outside
    static var selectedTabStatic: Int = 0
    
    let cuisineTypes: [String]
    let mealTypes: [String]
    let dietTypes: [String]
    let healthTypes: [String]
    let cookTimes: [Int]
    
    @Binding var selectedCuisineType: String?
    @Binding var selectedMealType: String?
    @Binding var selectedDietType: String?
    @Binding var selectedHealthType: String?
    @Binding var selectedMaxTime: Int?
    
    let onApply: () -> Void
    let onDismiss: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding()
            
            // Tab selector
            Picker("Filter Category", selection: $selectedTab) {
                Text("Cuisine").tag(0)
                Text("Meal").tag(1)
                Text("Diet").tag(2)
                Text("Health").tag(3)
                Text("Time").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onAppear {
                selectedTab = FiltersView.selectedTabStatic
            }
            
            // Filter options based on selected tab
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    switch selectedTab {
                    case 0:
                        filterGrid(items: cuisineTypes, selectedItem: $selectedCuisineType)
                    case 1:
                        filterGrid(items: mealTypes, selectedItem: $selectedMealType)
                    case 2:
                        filterGrid(items: dietTypes, selectedItem: $selectedDietType)
                    case 3:
                        filterGrid(items: healthTypes, selectedItem: $selectedHealthType)
                    case 4:
                        timeFilterView
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
            
            // Apply button
            Button(action: onApply) {
                Text("Apply Filters")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary3)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .frame(height: 450)
    }
    
    var timeFilterView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Maximum Cooking Time")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(cookTimes, id: \.self) { time in
                    Button(action: {
                        selectedMaxTime = selectedMaxTime == time ? nil : time
                    }) {
                        Text("\(time) min")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedMaxTime == time ? AppColors.secondary3 : Color.gray.opacity(0.15))
                            .cornerRadius(8)
                            .foregroundColor(selectedMaxTime == time ? .white : .black)
                    }
                }
            }
        }
    }
    
    func filterGrid<T: Hashable>(items: [String], selectedItem: Binding<T?>) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    if selectedItem.wrappedValue as? String == item {
                        selectedItem.wrappedValue = nil
                    } else {
                        selectedItem.wrappedValue = item as? T
                    }
                }) {
                    Text(item)
                        .font(.system(size: 14))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            (selectedItem.wrappedValue as? String) == item
                                ? AppColors.secondary3
                                : Color.gray.opacity(0.15)
                        )
                        .cornerRadius(8)
                        .foregroundColor(
                            (selectedItem.wrappedValue as? String) == item
                                ? .white
                                : .black
                        )
                }
            }
        }
    }
} 
