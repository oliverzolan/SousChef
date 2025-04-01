//
//  HomeHeader.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct HomeHeader: View {
    @Binding var showMenu: Bool
    
    var body: some View {
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
}

struct HomeSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
            if !searchText.isEmpty {
                NavigationLink(destination: RecipeListView(title: "Search Results", searchQuery: searchText)) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(AppColors.secondary3)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
} 
