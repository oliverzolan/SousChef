//
//  homepage_activity.swift
//  SousChef
//
//  Created by Bennet Rau on 10/28/24.
//

import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var userSession: UserSession // Access shared user session

    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    // Top Greeting Section with Safe Area Boundaries
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 180)
                            .edgesIgnoringSafeArea(.top)
                        
                        HStack {
                            Text(
                                    userSession.fullName?.isEmpty == false
                                    ? "Welcome Chef \n\(userSession.fullName!)"
                                    : "Welcome Chef" 
                                )
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                            Spacer()
                            NavigationLink(destination: SettingsView().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .padding(.leading, 8)
                        TextField("Search Recipes . . .", text: .constant(""))
                            .padding(.leading, 5)
                            .frame(height: 50)
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, 8)
                        
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.9), AppColors.gradientSearchBar]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 15) {
                            ForEach(["Mexican", "BBQ", "Chinese", "Italian", "Indian", "Korean"], id: \.self) { category in
                                Text(category)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(AppColors.cardColor)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    }
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ZStack {
                            // Background box with recipe content
                            VStack(alignment: .leading, spacing: 10) {
                                Spacer() // Adds space at the top
                                Text("Recipes")
                                    .font(.headline)
                                    .padding(.bottom, 10)
                                    .foregroundColor(.white)
                                
                                // Future space for recipe content goes here
                                Text("Recipe content goes here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.cardColor)
                            .cornerRadius(20)
                            
                            // Star icon positioned at the top-right corner within the box
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20))
                                        .padding(10)
                                        .foregroundColor(.yellow) // Optional color for the star
                                }
                                Spacer()
                            }
                            .cornerRadius(20) // Ensures corners match
                        }
                        .padding(.horizontal) // Outer padding if needed
                    }
                    
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: ReceiptPage()){
                            VStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 5)
                                    .foregroundColor(.white)
                                Text("Scan Receipt")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardColor)
                        .cornerRadius(20)
                        
                        // Shopping List Button
                        VStack {
                            Image(systemName: "cart")
                                .font(.system(size: 30))
                                .padding(.bottom, 5)
                                .foregroundColor(.white)
                            Text("Shopping List")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardColor)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)

                    Spacer()

                    
                    ZStack {
                        // Background for the bottom navigation
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 100)
                            .ignoresSafeArea(edges: .bottom)
                        
                        // Bottom navigation buttons
                        HStack {
                            Spacer()
                            //Pantry
                            VStack {
                                NavigationLink(destination: PantryPage()
                                    .navigationBarBackButtonHidden(true)) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 40))
                                }
                                
                            }
                            Spacer()
                            //Camera
                            VStack {
                                NavigationLink(destination: ScanIngredientPage()
                                    //.navigationBarBackButtonHidden(true)
                                ){
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .padding()
                                }
                            }
                            Spacer()
                            //Ask AI
                            VStack {
                                NavigationLink(destination: AskAIPage()){
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 40))
                                }
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    }
                    .frame(width: geometry.size.width)
                    .edgesIgnoringSafeArea(.all)
                }
                .frame(width: geometry.size.width)
                .background(AppColors.background)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserSession())
            .previewDevice("iPhone 16 Pro")
    }
}
