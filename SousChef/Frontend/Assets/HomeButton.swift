//
//  home.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import SwiftUI

struct HomeButton: View {
    var body: some View {
        NavigationLink(
            destination: homepage_activity()
                .navigationBarBackButtonHidden(true) // Hide back button
        ) {
            Image(systemName: "house.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(AppColors.cardColor))
                .shadow(radius: 5)
        }
    }
}
