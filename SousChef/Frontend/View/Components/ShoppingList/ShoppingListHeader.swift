//
//  ShoppingListHeader.swift
//  SousChef
//
//  Created by Zac Waiksnoris on 4/25/25.
//

import SwiftUI

struct ShoppingListHeader: View {
    var body: some View {
        VStack {
            HStack {
                Text("Shopping List")
                    .font(.system(size: 28))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.leading, 16)

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 4)
        }
        .background(Color.white)
    }
}

struct ShoppingListHeader_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListHeader()
            .previewLayout(.sizeThatFits)
    }
}
