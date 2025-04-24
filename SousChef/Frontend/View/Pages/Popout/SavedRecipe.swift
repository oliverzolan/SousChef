import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct SavedRecipe: Identifiable {
    let id: String
    let title: String
    let imageURL: URL?
    let url: URL?
}


class SavedRecipesViewModel: ObservableObject {
    @Published var recipes: [SavedRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchSavedRecipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil

        db.collection("users")
            .document(uid)
            .collection("savedRecipes")
            .order(by: "savedAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.recipes = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        let title = data["label"] as? String ?? "Untitled"
                        let imageString = data["image"] as? String
                        let urlString = data["url"] as? String
                        return SavedRecipe(
                            id: doc.documentID,
                            title: title,
                            imageURL: imageString.flatMap(URL.init),
                            url: urlString.flatMap(URL.init)
                        )
                    } ?? []
                }
            }
    }
}


struct SavedRecipesView: View {
    @StateObject private var viewModel = SavedRecipesViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppColors.primary2)
                } else {
                    List(viewModel.recipes) { recipe in
                        Button {
                            if let url = recipe.url {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if let url = recipe.imageURL {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        default:
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text(recipe.title)
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.fetchSavedRecipes()
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationTitle("Saved Recipes")
            .onAppear {
                viewModel.fetchSavedRecipes()
            }
        }
    }
}


struct SavedRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedRecipesView()
    }
}
