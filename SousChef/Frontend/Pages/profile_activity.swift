//
//  profile_activity.swift
//  SousChef
//
//  Created by Bennet Rau on 11/8/24.
//

import SwiftUI

struct profile_activity: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    
                    HStack {
                    
                        HomeButton()
                            .frame(width: 20, height: 20) // Adjust size
                            .padding(.leading, 40)
                            .padding(.top, 10)
                        
                        Spacer()

                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(AppColors.cardColor))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    Text("User Login Page")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                    
                    // Navigation to Login View
                    NavigationLink(
                        destination: LoginView()
                            .navigationBarBackButtonHidden(true) // Hide the back button
                    ) {
                        Text("Go to Login")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Navigation to Create Account View
                    NavigationLink(
                        destination: CreateAccountView()
                            .navigationBarBackButtonHidden(true) // Hide the back button
                    ) {
                        Text("Create New Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer() // Push content to the middle
                }
            }
            .navigationBarBackButtonHidden(true) // Hide back button for this view
        }
    }
}

struct profile_activity_Previews: PreviewProvider {
    static var previews: some View {
        profile_activity()
            .previewDevice("iPhone 12")
    }
}
