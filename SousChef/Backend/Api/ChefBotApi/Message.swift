//
//  Message.swift
//  SousChef
//
//  Created by Bennet Rau on 4/3/25.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var isTyping: Bool = false
}
