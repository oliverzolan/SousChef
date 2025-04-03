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
    @State private var navigateToSearch = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 18))
            
            TextField("Search recipes...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .submitLabel(.search)
                .tint(.blue)
                .onSubmit {
                    if !searchText.isEmpty {
                        navigateToSearch = true
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .overlay(
            NavigationLink(
                destination: RecipeListView(title: "Search Results", searchQuery: searchText),
                isActive: $navigateToSearch
            ) {
                EmptyView()
            }
        )
    }
}
