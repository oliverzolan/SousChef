import SwiftUI
import FirebaseFirestore

struct HelpArticle: Identifiable {
    let id: String
    let title: String
    let summary: String
    let content: String
}

class HelpViewModel: ObservableObject {
    @Published var articles: [HelpArticle] = []
    private let db = Firestore.firestore()

    init() {
        fetchArticles()
    }

    func fetchArticles() {
        db.collection("helpArticles")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.articles = docs.compactMap { doc in
                        let data = doc.data()
                        guard
                            let title = data["title"] as? String,
                            let summary = data["summary"] as? String,
                            let content = data["content"] as? String
                        else { return nil }
                        return HelpArticle(
                            id: doc.documentID,
                            title: title,
                            summary: summary,
                            content: content
                        )
                    }
                }
            }
    }
}

struct HelpListView: View {
    @StateObject private var viewModel = HelpViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                List(viewModel.articles) { article in
                    NavigationLink(destination: HelpDetailView(article: article)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.title)
                                .font(.headline)
                            Text(article.summary)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Help & Tutorials")
        }
    }
}

struct HelpDetailView: View {
    let article: HelpArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title)
                    .fontWeight(.semibold)
                Text(article.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
