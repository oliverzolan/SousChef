//
//  LocationComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI

struct LocationComponent: View {
    var location: String

    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
                .foregroundColor(.black)

            Text(location)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()
        }
        .padding()
    }
}
