//
//  popup_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct PantryPopupView: View {
    @Binding var isVisible: Bool // Control visibility of popup
    @Binding var pantryItems: [String] // Bind to pantry items list

    @State private var newItem: String = "" // State for new item input

    var body: some View {
        VStack {
            Text("Add New Pantry Item")
                .font(.headline)
                .padding()

            TextField("Enter item name", text: $newItem)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: {
                    isVisible = false // Close popup without action
                }) {
                    Text("Cancel")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    if !newItem.isEmpty {
                        pantryItems.append(newItem) // Add new item to pantry
                        newItem = "" // Clear the input field
                        isVisible = false // Close popup
                    }
                }) {
                    Text("Add")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isVisible = false // Dismiss popup when tapping outside
                }
        )
    }
}
