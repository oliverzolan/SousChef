//
//  recipe_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct receipt_activity: View {
    var body: some View {
        VStack {
            Text("Welcome to Recipe Activity")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("This is the placeholder for your recipe content.")
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            Spacer() // To push content to the top
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct receipt_activity_Previews: PreviewProvider {
    static var previews: some View {
        receipt_activity()
    }
}
