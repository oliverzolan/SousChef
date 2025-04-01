//
//  RecipeGrid.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import SwiftUI

struct RecipeGrid<Item, Content>: View where Item: Identifiable, Content: View {
    let items: [Item]
    let rowCount: Int
    let itemBuilder: (Item) -> Content
    let spacing: CGFloat
    
    init(items: [Item], 
         rowCount: Int = 2, 
         spacing: CGFloat = 16,
         @ViewBuilder itemBuilder: @escaping (Item) -> Content) {
        self.items = items
        self.rowCount = rowCount
        self.spacing = spacing
        self.itemBuilder = itemBuilder
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: rowCount),
            spacing: spacing
        ) {
            ForEach(items) { item in
                itemBuilder(item)
            }
        }
    }
}

struct RecipeGrid_Generic: View {
    let items: [(String, String)]
    let rowCount: Int
    let itemBuilder: (String, String) -> AnyView
    
    init(
        items: [(String, String)],
        rowCount: Int = 2,
        @ViewBuilder itemBuilder: @escaping (String, String) -> some View
    ) {
        self.items = items
        self.rowCount = rowCount
        self.itemBuilder = { AnyView(itemBuilder($0, $1)) }
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: rowCount),
            spacing: 16
        ) {
            ForEach(items.indices, id: \.self) { index in
                itemBuilder(items[index].0, items[index].1)
            }
        }
    }
}

struct RecipeCardsGrid: View {
    let recipes: [EdamamRecipeModel]
    let rowCount: Int
    let onLoadMore: (() -> Void)?
    let isLoading: Bool
    let hasMoreItems: Bool
    
    init(
        recipes: [EdamamRecipeModel],
        rowCount: Int = 2,
        isLoading: Bool = false,
        hasMoreItems: Bool = false,
        onLoadMore: (() -> Void)? = nil
    ) {
        self.recipes = recipes
        self.rowCount = rowCount
        self.isLoading = isLoading
        self.hasMoreItems = hasMoreItems
        self.onLoadMore = onLoadMore
    }
    
    var body: some View {
        VStack {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: rowCount),
                spacing: 16
            ) {
                ForEach(recipes, id: \.url) { recipe in
                    RecipeGridItem(
                        recipe: recipe,
                        width: (UIScreen.main.bounds.width - (CGFloat(rowCount + 1) * 16)) / CGFloat(rowCount),
                        height: 180
                    )
                }
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            } else if hasMoreItems, let loadMore = onLoadMore {
                Button(action: loadMore) {
                    Text("Load More")
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(AppColors.secondary3)
                        .cornerRadius(8)
                }
                .padding(.vertical)
            }
        }
    }
}
