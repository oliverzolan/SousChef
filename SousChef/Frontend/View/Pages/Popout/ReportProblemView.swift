import SwiftUI
import FirebaseFirestore

class ReportProblemViewModel: ObservableObject {
    @Published var subject = ""
    @Published var description = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var navigateBack = false

    private let db = Firestore.firestore()

    func submitReport() {
        guard !subject.trimmingCharacters(in: .whitespaces).isEmpty,
              !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        isLoading = true
        errorMessage = nil
        let data: [String: Any] = [
            "subject": subject,
            "description": description,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("reports")
            .addDocument(data: data) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
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
        }
        .onChange(of: viewModel.navigateBack) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}
