//
//  homepage_activity.swift
//  SousChef
//
//  Created by Bennet Rau on 10/28/24.
//

import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var userSession: UserSession // Access shared user session
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil // Track selected category

    let categories = ["Mexican", "French", "Italian", "American", "Greek", "Chinese", "Indian", "Middle Eastern", "Thai"]

    var body: some View {
        NavigationView {
            VStack {
                // Header
                Spacer().frame(height: 70)
                HStack {
                    Text("Chef John Paul Gaultier")
                        .font(.custom("Inter-Bold", size: 24))
                    Spacer()
                    HStack(spacing: 16) {
                        //Notification Bell
                        Button(action: {
                            //implement action
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
                        //3 Lines
                        Button(action: {
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)

                // Search Bar
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Cuisine Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = (selectedCategory == category) ? nil : category
                            }) {
                                Text(category)
                                    .font(.custom("Inter-Bold", size: 15))
                                    .foregroundColor(selectedCategory == category ? .white : .black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(selectedCategory == category ? AppColors.secondary3 : AppColors.lightGray)                                     .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Featured Recipe Card
                FeaturedRecipeView()

                // Featured Recipes Grid
                SectionHeader(title: "Featured Recipes")
                RecipeGrid()

                // Seasonal Recipes Grid
                SectionHeader(title: "Seasonal Recipes")
                RecipeGrid()

                // Scan Buttons
                
                Spacer() // Pushes content to the top
            }
        }
    }
}

struct CuisineCategory: View {
    var name: String
    var isSelected: Bool

    var body: some View {
        Text(name)
            .font(.headline)
            .foregroundColor(isSelected ? .white : .black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.secondary3 : AppColors.lightGray)
            .cornerRadius(20)
    }
}

struct FeaturedRecipeView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("shrimp_jambalaya") // Change to IMAGE
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text("Shrimp Jambalaya")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Allows it to grow
        }
        .padding(.horizontal)
    }
}


struct SectionHeader: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct RecipeGrid: View {
    var body: some View {
        HStack() {
            //Tall Left Button
            RoundedColorButton(title: "Button 1", color: .gray, width: 150, height: 160)

            VStack(spacing: 10) {
                //Top right button
                RoundedColorButton(title: "Button 2", color: .gray, width: 200, height: 75)

                HStack(spacing: 10) {
                    //Bottom Two buttons same size
                    RoundedColorButton(title: "Button 3", color: .gray, width: 100, height: 75)
                    RoundedColorButton(title: "Button 4", color: .gray, width: 100, height: 75)
                }
            }
        }
        .padding()
    }
}

struct RoundedColorButton: View {
    var title: String
    var color: Color
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
        }
    }
}




struct ScanButton: View {
    var title: String
    
    var body: some View {
        Button(action: {
            // Scan action
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10)
        }
    }
}

// MARK: - SwiftUI Preview for Canvas Mode
struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserSession()) // Ensure the user session is injected
    }
}
