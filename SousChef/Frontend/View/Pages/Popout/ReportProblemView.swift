import SwiftUI
import FirebaseAuth
import FirebaseFirestore

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ReportProblemViewModel: ObservableObject {
    @Published var subject        = ""
    @Published var description    = ""
    @Published var isLoading      = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var navigateBack   = false

    private let db = Firestore.firestore()

    func submitReport() {
        // 1) must be logged in
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to submit a report."
            return
        }

        // 2) validate inputs
        guard !subject.trimmingCharacters(in: .whitespaces).isEmpty,
              !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }

        isLoading    = true
        errorMessage = nil

        // 3) build payload
        let data: [String: Any] = [
            "subject":     subject,
            "description": description,
            "createdAt":   FieldValue.serverTimestamp(),
            "reportedBy":  user.uid
        ]

        // 4) submit to Firestore
        db.collection("reports")
          .addDocument(data: data) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let nsErr = error as NSError? {
                    // map the nested Code enum
                    if let code = FirestoreErrorCode.Code(rawValue: nsErr.code),
                       code == .permissionDenied {
                        self?.errorMessage = "You don’t have permission to submit a report."
                    } else {
                        self?.errorMessage = nsErr.localizedDescription
                    }
                } else {
                    self?.successMessage = "Report sent. Thank you!"
                    self?.navigateBack = true
                }
            }
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
