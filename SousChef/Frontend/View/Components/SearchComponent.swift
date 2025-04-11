//
//  SearchComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI


struct SearchComponent: View {
    @Binding var searchText: String
    var searchQuery: String
    var onSubmit: ((String) -> Void)?
    @FocusState var isSearchFieldFocused: Bool

    // Constructor for binding searchQuery with onSubmit
    init(searchText: Binding<String>, searchQuery: Binding<String>, onSubmit: ((String) -> Void)? = nil, isSearchFieldFocused: FocusState<Bool>) {
        self._searchText = searchText
        self.searchQuery = searchQuery.wrappedValue
        self.onSubmit = onSubmit
        self._isSearchFieldFocused = isSearchFieldFocused
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)

            TextField("Search \(searchQuery)...", text: $searchText)
                .font(.system(size: 16))
                .padding(10)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    if let onSubmit = onSubmit, !searchText.isEmpty {
                        onSubmit(searchText)
                    }
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isSearchFieldFocused = false
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { value in
                    if value.translation.height > 0 && abs(value.translation.width) < abs(value.translation.height) {
                        // Swiped down
                        isSearchFieldFocused = false
                    }
                }
        )    }
}
