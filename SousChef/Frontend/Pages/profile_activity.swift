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
            // Add any other UI elements for your login page here
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
