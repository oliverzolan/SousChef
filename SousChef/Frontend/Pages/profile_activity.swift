//
//  profile_activity.swift
//  SousChef
//
//  Created by Bennet Rau on 11/8/24.
//

import SwiftUI


struct profile_activity: View {
    var body: some View {
        VStack {
            Text("User Login Page")
                .font(.title)
                .padding()
            // Button to go to the Login View
                           NavigationLink(destination: LoginView()) {
                               Text("Go to Login")
                                   .font(.headline)
                                   .foregroundColor(.white)
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.blue)
                                   .cornerRadius(8)
                                   .padding(.horizontal)
                           }

            // Button to go to the Create Account View
                           NavigationLink(destination: CreateAccountView()) {
                               Text("Create New Account")
                                   .font(.headline)
                                   .foregroundColor(.white)
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.green)
                                   .cornerRadius(8)
                                   .padding(.horizontal)
                           }
        }
        .background(Color.white) // Customize background color if needed
        .edgesIgnoringSafeArea(.all)
    }
}

struct UserLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        profile_activity()
            .previewDevice("iPhone 12")
    }
}
