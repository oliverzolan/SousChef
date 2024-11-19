//
//  popup_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct PopupView: View {
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Popup Title")
                .font(.headline)
            Text("This is the content of the popup box.")
                .multilineTextAlignment(.center)

            Button(action: {
                isVisible = false // Close the popup
            }) {
                Text("Close")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 20)
        .frame(maxWidth: 300)
    }
}
