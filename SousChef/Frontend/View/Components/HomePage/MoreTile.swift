//
//  MoreTile.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/30/25.
//

import SwiftUI

struct MoreTile: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Image("redMore")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
    }
}
