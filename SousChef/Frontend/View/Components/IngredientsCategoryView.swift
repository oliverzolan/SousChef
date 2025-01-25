//
//  IngredientsCategoryView.swift
//  SousChef
//
//  Created by Garry Gomes on 12/31/24.
//

import SwiftUI

struct IngredientCategoryView: View {
    let category: String
    let items: [String]
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            // Category Header
            HStack {
                Text(category)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(items.count) Items")
                    .font(.subheadline)
            }
            .padding(.vertical, 8)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            // Expanded Items
            if isExpanded {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        Text("Calorie | 10")
                            .font(.footnote)
                        Text("Quantity | 1")
                            .font(.footnote)
                        Text("Exp | 11/12/24")
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}
