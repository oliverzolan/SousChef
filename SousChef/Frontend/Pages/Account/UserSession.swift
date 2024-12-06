//
//  UserSession.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/5/24.
//

import Foundation

class UserSession: ObservableObject {
    @Published var token: String? // Published to notify views of changes

    init() {
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
    }

    func logout() {
        KeychainHelper.shared.delete(for: "authToken")
        self.token = nil
    }
}
