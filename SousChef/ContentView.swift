//
//  ContentView.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds, Bennet Rau on 10/26/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(.tint)
            Text("SousChef App")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
