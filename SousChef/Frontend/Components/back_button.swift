//
//  back_button.swift
//  SousChef
//
//  Created by Bennet Rau on 12/11/24.
//

import SwiftUI

struct BackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Image(systemName: "chevron.left") // Use a system image or custom asset
                    .font(.system(size: 20, weight: .bold))
                Text("Back")
                    .font(.headline)
            }
            .foregroundColor(.white) // Change color if needed
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.0)) // Optional background color
            .cornerRadius(10)
            .shadow(radius: 3)
        }
    }
}
