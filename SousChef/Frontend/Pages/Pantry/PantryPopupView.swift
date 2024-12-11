//
//  PantryItem.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/8/24.
//

import SwiftUI
import FirebaseAuth

struct PantryPopupView: View {
    @Binding var isVisible: Bool
    @Binding var pantryItems: [String]
    @State private var ingredients: [Ingredient] = []
    @State private var quantities: [Int: Int] = [:]
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isVisible = false // Dismiss when tapping outside
                }
            
            // Popup content
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Text("Add Ingredient")
                        .font(.headline)
                        .padding()
                    
                    if isLoading {
                        ProgressView("Loading Ingredients...")
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(ingredients) { ingredient in
                                    VStack {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(ingredient.name)
                                                    .font(.headline)
                                                Text(ingredient.category)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 5)
                                        
                                        // Quantity adjustment buttons
                                        HStack {
                                            Button(action: {
                                                decreaseQuantity(for: ingredient.id)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.system(size: 25))
                                                    .foregroundColor(.red)
                                            }
                                            Text("\(quantities[ingredient.id, default: 0])")
                                                .font(.headline)
                                                .frame(width: 40, alignment: .center)
                                            Button(action: {
                                                increaseQuantity(for: ingredient.id)
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 25))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.cardColor)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .frame(maxHeight: 500) // Maximum scrollable height for the list
                    }
                }
                
                Spacer()
                
                // Add to Pantry button always visible at the bottom
                VStack {
                    Button(action: {
                        addSelectedIngredientsToPantry()
                        isVisible = false
                    }) {
                        Text("Add to Pantry")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isVisible = false
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .frame(maxWidth: 400) // Optional: Limit the maximum width of the popup
            .padding(.horizontal, 30) // Ensure popup doesn't touch the edges
        }
        .onAppear {
            fetchIngredients()
        }
    }
    
    private func fetchIngredients() {
        guard let url = URL(string: "https://souschef.click/ingredients/all") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch ingredients: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let fetchedIngredients = try JSONDecoder().decode([Ingredient].self, from: data)
                    self.ingredients = fetchedIngredients
                } catch {
                    self.errorMessage = "Failed to decode ingredients: \(error.localizedDescription)"
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON causing error: \(jsonString)")
                    }
                }
            }
        }.resume()
    }
    
    private func increaseQuantity(for ingredientID: Int) {
        quantities[ingredientID, default: 0] += 1
    }
    
    private func decreaseQuantity(for ingredientID: Int) {
        let currentQuantity = quantities[ingredientID, default: 0]
        if currentQuantity > 0 {
            quantities[ingredientID] = currentQuantity - 1
        }
    }
    
    private func addSelectedIngredientsToPantry() {
        guard let url = URL(string: "https://souschef.click/pantry/user/add-ingredients") else {
            errorMessage = "Invalid URL"
            return
        }
        
        // Retrieve and refresh the Firebase token
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                self.errorMessage = "Failed to refresh token: \(error.localizedDescription)"
                return
            }
            
            guard let idToken = idToken else {
                self.errorMessage = "Failed to retrieve Firebase token"
                return
            }
            
            // Prepare the payload
            let selectedIngredients = self.quantities.compactMap { (ingredientID, quantity) -> [String: Any]? in
                guard quantity > 0 else { return nil }
                return ["ingredient_id": ingredientID, "quantity": quantity]
            }
            
            print(idToken)
            print(selectedIngredients)
            
            guard !selectedIngredients.isEmpty else {
                self.errorMessage = "No ingredients selected"
                return
            }
            
            let payload: [String: Any] = ["ingredients": selectedIngredients]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            } catch {
                self.errorMessage = "Failed to encode request payload: \(error.localizedDescription)"
                return
            }
            
            // Send the POST request
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Failed to add ingredients: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                        self.errorMessage = "Failed to add ingredients: Invalid server response"
                        return
                    }
                    
                    // Successfully added ingredients
                    print("Ingredients successfully added to pantry")
                    self.isVisible = false
                }
            }.resume()
        }
    }
    
}
