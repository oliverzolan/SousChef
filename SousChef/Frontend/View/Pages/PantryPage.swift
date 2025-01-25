//
//  pantry_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct PantryPage: View {
    @State private var isPopupVisible: Bool = false
    @State private var pantryItems: [String] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 120)
                            .edgesIgnoringSafeArea(.top)
                            .padding(.top, 30)

                        HStack(spacing: 15) {
                            // back buttn
                            NavigationLink(destination: HomePage()
                                .navigationBarBackButtonHidden(true)
                                .transition(.move(edge: .leading))
                            ){
                             
                                //back
                                Text("←")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .contentShape(Rectangle())
                            
                            }
                            .padding(.leading, 20)

                            
                            Text("Welcome to Your Pantry")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }


                    
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(pantryItems, id: \.self) { item in
                                    HStack {
                                        Text(item)
                                            .font(.headline)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppColors.cardColor)
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Add Ing.
                    Button(action: {
                        isPopupVisible.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 60, height: 60)

                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(radius: 5)

                    // Bottom Nav
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 150)
                            .edgesIgnoringSafeArea(.bottom)

                        VStack {
                            Text("Categories")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(["Vegetables", "Fruits", "Meats", "Grains", "Dairy", "Snacks"], id: \.self) { category in
                                        Button(action: {
                                            //when we want to filter
                                            
                                        }) {
                                            Text(category)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                                .background(AppColors.cardColor)
                                                .cornerRadius(20)
                                                .shadow(radius: 3)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack {
                                Spacer()
                                NavigationLink(destination: HomePage()) {
                                    VStack {
                                        Image(systemName: "house.fill")
                                            .font(.system(size: 30))
                                        Text("Home")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                                NavigationLink(destination: ReceiptPage()) {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                        Text("Scan")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                                NavigationLink(destination: AskAIPage()) {
                                    VStack {
                                        Image(systemName: "questionmark.circle")
                                            .font(.system(size: 30))
                                        Text("Ask AI")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                }
                .background(AppColors.background)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    fetchPantryItems()
                }
                .overlay(
                    isPopupVisible ? PantryPopupView(isVisible: $isPopupVisible, pantryItems: $pantryItems) : nil
                )
                .animation(.easeInOut, value: isPopupVisible)
            }
        }
    }

    private func fetchPantryItems() {
        guard let url = URL(string: "https://souschef.click/pantry/user") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = userSession.token else {
            errorMessage = "User is not authenticated"
            isLoading = false
            return
        }
        request.addValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        break
                    case 401:
                        self.handleTokenExpiration()
                        return
                    default:
                        self.errorMessage = "Error: Server returned status code \(httpResponse.statusCode)"
                        return
                    }
                }

                if let error = error {
                    self.errorMessage = "Failed to load pantry items: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }

                do {
                    let items = try JSONDecoder().decode([PantryItem].self, from: data)
                    self.pantryItems = items.map { $0.ingredient_name }
                } catch {
                    self.errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func handleTokenExpiration() {
        userSession.refreshToken { newToken in
            guard let newToken = newToken else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to refresh token. Please log in again."
                    self.isLoading = false
                }
                return
            }

            self.fetchPantryItems()
        }
    }
}

struct pantry_activity_view: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.token = "mock_token"

        return PantryPage()
            .environmentObject(mockSession)
            .previewDevice("iPhone 12")
    }
}
