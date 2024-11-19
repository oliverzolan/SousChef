//
//  ContentView.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds, Bennet Rau on 10/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var result = "No result"

    var body: some View {
        VStack {
            CameraView(result: $result)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
            
            Text(result)
                .padding()
                .font(.title)
                .multilineTextAlignment(.center)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
