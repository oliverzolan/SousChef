import FirebaseAuth

class SettingsViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email       = ""
    @Published var newPassword = ""
    @Published var errorMessage: String?
    @Published var updateSuccess = false

    func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        displayName = user.displayName ?? ""
        email       = user.email       ?? ""
    }

    func updateUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let group = DispatchGroup()
        var authError: Error?

        group.enter()
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { err in
            if let err = err { authError = err }
            group.leave()
        }

        if email != user.email {
            group.enter()
            user.updateEmail(to: email) { err in
                if let err = err { authError = err }
                group.leave()
            }
        }

        if !newPassword.isEmpty {
            group.enter()
            user.updatePassword(to: newPassword) { err in
                if let err = err { authError = err }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let err = authError {
                self.errorMessage = err.localizedDescription
            } else {
                self.updateSuccess = true
            }
        }
    }
}
