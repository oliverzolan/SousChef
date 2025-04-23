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
    @Published var updateSuccess = false

    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // Format display name to include Chef prefix
    private func formatDisplayName(_ name: String) -> String {
        if name.isEmpty {
            return "SousChef"
        }
        
        // If name already starts with "Chef", return as is
        if name.hasPrefix("Chef ") {
            return name
        }
        
        // Add "Chef" prefix
        return "Chef \(name)"
    }

    func loadUserData() {
        guard let user = auth.currentUser else { return }
        
        email = user.email ?? ""
        
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.displayName = data["displayName"] as? String ?? "SousChef"
                    self.fullName = data["fullName"] as? String ?? ""
                }
            }
        }
    }

    func updateUserInfo() {
        guard let user = auth.currentUser else { return }
        
        // Format the display name
        let formattedDisplayName = formatDisplayName(displayName)

        // Update Auth display name
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = formattedDisplayName
        changeRequest.commitChanges { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error updating display name: \(error.localizedDescription)"
                }
                return
            }
            
            // Post notification for name change
            NotificationCenter.default.post(
                name: NSNotification.Name("UserDisplayNameChanged"),
                object: nil,
                userInfo: ["displayName": formattedDisplayName]
            )
        }
        
        // Update Firestore
        let userRef = db.collection("users").document(user.uid)
        userRef.updateData([
            "displayName": formattedDisplayName,
            "fullName": fullName
        ]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error updating profile: \(error.localizedDescription)"
                }
                return
            }
            
            // Mark update as successful
            DispatchQueue.main.async {
                self.updateSuccess = true
            }
        }

        // Update Email if changed
        if email != user.email {
            user.updateEmail(to: email) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error updating email: \(error.localizedDescription)"
                    }
                }
            }
        }

        // Update Password if provided
        if !newPassword.isEmpty {
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error updating password: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
