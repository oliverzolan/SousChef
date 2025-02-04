//
//  Untitled.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 2/4/25.
//

import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class SettingsViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var fullName = ""
    @Published var newPassword = ""
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    func loadUserData() {
        guard let user = auth.currentUser else { return }
        
        email = user.email ?? ""
        
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.displayName = data["displayName"] as? String ?? ""
                self.fullName = data["fullName"] as? String ?? ""
            }
        }
    }

    func updateUserInfo() {
        guard let user = auth.currentUser else { return }

        // Update Firestore
        let userRef = db.collection("users").document(user.uid)
        userRef.updateData([
            "displayName": displayName,
            "fullName": fullName
        ]) { error in
            if let error = error {
                self.errorMessage = "Error updating profile: \(error.localizedDescription)"
                return
            }
        }

        // Update Email if changed
        if email != user.email {
            user.updateEmail(to: email) { error in
                if let error = error {
                    self.errorMessage = "Error updating email: \(error.localizedDescription)"
                }
            }
        }

        // Update Password if provided
        if !newPassword.isEmpty {
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.errorMessage = "Error updating password: \(error.localizedDescription)"
                }
            }
        }
    }
}
