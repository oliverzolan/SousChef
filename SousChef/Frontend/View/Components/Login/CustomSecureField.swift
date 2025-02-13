//
//  CustomSecureField.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 2/1/25.
//

import SwiftUI
import AuthenticationServices

struct CustomSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            SecureField(placeholder, text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        }
    }
}
