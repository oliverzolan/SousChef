import SwiftUI
import FirebaseAuth

class ReportProblemViewModel: ObservableObject {
    @Published var subject        = ""
    @Published var description    = ""
    @Published var isLoading      = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var navigateBack   = false

    func submitReport() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to submit a report."
            return
        }

        guard !subject.trimmingCharacters(in: .whitespaces).isEmpty,
              !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        user.getIDToken { idToken, error in
            guard let idToken = idToken, error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to get auth token."
                    self.isLoading = false
                }
                return
            }
            print("idToken: \(idToken)")
            let url = URL(string: "https://souschef.click/reports/add")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(idToken, forHTTPHeaderField: "Authorization")

            let payload: [String: Any] = [
                "subject": self.subject,
                "description": self.description
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Encoding error."
                    self.isLoading = false
                }
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 201 {
                            self.successMessage = "Report sent. Thank you!"
                            self.navigateBack = true
                        } else {
                            if let data = data,
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let message = json["error"] as? String {
                                self.errorMessage = message
                            } else {
                                self.errorMessage = "Server error (code: \(httpResponse.statusCode))"
                            }
                        }
                    }
                }
            }.resume()
        }
    }
}

struct ReportProblemView: View {
    @StateObject private var viewModel = ReportProblemViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Report a Problem")
                            .font(.title)
                            .fontWeight(.medium)
                            .padding(.top, 40)

                        VStack(spacing: 16) {
                            CustomTextField(
                                label: "Subject",
                                placeholder: "Brief summary",
                                text: $viewModel.subject
                            )
                            .padding(.horizontal, 24)

                            ZStack(alignment: .topLeading) {
                                if viewModel.description.isEmpty {
                                    Text("Describe the issue...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 30)
                                        .padding(.top, 12)
                                }
                                TextEditor(text: $viewModel.description)
                                    .frame(minHeight: 150)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5))
                                    )
                                    .padding(.horizontal, 24)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        } else if let success = viewModel.successMessage {
                            Text(success)
                                .foregroundColor(.green)
                                .padding(.horizontal, 24)
                        }

                        Button(action: viewModel.submitReport) {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Submit")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.primary2)
                            )
                        }
                        .padding(.horizontal, 24)
                        .disabled(viewModel.isLoading)

                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: viewModel.navigateBack) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}
