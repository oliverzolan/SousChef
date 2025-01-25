//
//  PantryFeatureComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI

struct ScanFeaturesComponent: View {
    var body: some View {
        HStack(spacing: 32) {
            VStack {
                Image(systemName: "doc.text.viewfinder")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Scan Receipt")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            VStack {
                Image(systemName: "refrigerator.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Scan Fridge")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            VStack {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Food Based on Pantry")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}
