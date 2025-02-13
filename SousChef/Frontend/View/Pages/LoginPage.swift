//
//  LoginPage.swift
//  SousChef
//
//  Created by Bennet Rau on 11/8/24.
//

import SwiftUI

struct LoginPage: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                        Text("SousChef")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                            .padding(.vertical, 200)
                        //to login
                        NavigationLink(
                            destination: LoginView()
                            // use this to hide apple automatic back button
                                .navigationBarBackButtonHidden(true)
                        ) {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(AppColors.primary1)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // Navigation to Create Account View
                        NavigationLink(
                            destination: CreateAccountView()
                                .navigationBarBackButtonHidden(true) // Hide the back button
                        ) {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(AppColors.primary2)
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
            LoginPage()
                .previewDevice("iPhone 12")
        }
    }

