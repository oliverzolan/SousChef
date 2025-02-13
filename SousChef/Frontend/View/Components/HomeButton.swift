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
            destination: HomePage()
                .navigationBarBackButtonHidden(true) // Hide back button
        ) {
            Image(systemName: "house.fill")
                .font(.system(size: 25))
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(AppColors.secondary2))
                .shadow(radius: 5)
        }
    }
}
