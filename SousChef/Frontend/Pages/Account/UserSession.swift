//
//  UserSession.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import Foundation

class UserSession: ObservableObject {
    @Published var token: String? // For authenticated users
    @Published var isGuest: Bool = false // For guest users

    init() {
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
    }

    func loginAsGuest() {
        isGuest = true
    }

    func logout() {
        KeychainHelper.shared.delete(for: "authToken")
        self.token = nil
        self.isGuest = false
    }
}
