//
//  askAI_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct AskAIPage: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Welcome to Ask AI Activity")
                    .font(.title)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.top, 50)
            }
        }
        .navigationTitle("Ask AI")
    }
}

