//
//  ChatHeader.swift
//  SousChef
//
//  Created by Bennet Rau on 4/3/25.
//

import SwiftUI

struct ChatHeader: View {
    var onNewChat: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Personal SousChef")
                    .font(.system(size: 28))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.leading, 16)

                Spacer()

                Button(action: {
                    onNewChat()
                }) {
                    Text("New Chat")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.trailing, 16)
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

struct ChatHeader_Previews: PreviewProvider {
    static var previews: some View {
        ChatHeader(onNewChat: {})
            .previewLayout(.sizeThatFits)
    }
}
