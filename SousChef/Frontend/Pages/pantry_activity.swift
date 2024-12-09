//
//  pantry_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct pantry_activity: View {
    @State private var isPopupVisible: Bool = false // State to control popup visibility
    @State private var pantryItems: [String] = [] // Pantry items loaded from the server
    @State private var isLoading: Bool = true // State to show loading indicator
    @State private var errorMessage: String? = nil // Error message state
    @EnvironmentObject var userSession: UserSession // Access the user session

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Your Pantry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                if isLoading {
                    ProgressView("Loading...") // Show a loading indicator
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)") // Show error if fetching fails
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Pantry Items List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(pantryItems, id: \.self) { item in
                                HStack {
                                    Text(item)
                                        .font(.headline)
                                        .padding()
                                        .background(AppColors.cardColor)
                                        .cornerRadius(10)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer()

                // Plus Button
                Button(action: {
                    isPopupVisible.toggle() // Toggle the popup visibility
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .onAppear {
                fetchPantryItems() // Fetch pantry data from server when view appears
            }
            .overlay(
                // Popup Box
                isPopupVisible ? PantryPopupView(isVisible: $isPopupVisible, pantryItems: $pantryItems) : nil
            )
            .animation(.easeInOut, value: isPopupVisible) // Smooth transition
        }
    }

    // Function to fetch pantry items from AWS server using user token
    private func fetchPantryItems() {
        guard let url = URL(string: "http://3.89.134.6:5000/pantry/user") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Use the token from the UserSession
        if let token = userSession.token {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "User is not authenticated"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false // Stop loading indicator

                if let error = error {
                    errorMessage = "Failed to load pantry items: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received from server"
                    return
                }

                do {
                    let items = try JSONDecoder().decode([String].self, from: data) // Decode the JSON response
                    pantryItems = items // Update pantry items with server data
                } catch {
                    errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
