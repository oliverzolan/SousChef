//
//  OpeningPage.swift
//  SousChef
//
//  Created by Garry Gomes on 12/31/24.
//

import SwiftUI

struct OpeningPage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Sign In Button
                NavigationLink(destination: SignInPage()) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Create Account Button
                NavigationLink(destination: CreateAccountPage()) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

            }
        }
    }
}

struct OpeningPage_Previews: PreviewProvider {
    static var previews: some View {
        OpeningPage()
    }
}
