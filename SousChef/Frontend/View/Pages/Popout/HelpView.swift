import SwiftUI

struct HelpListView: View {
    let articles = HelpArticle.all

    var body: some View {
        NavigationStack {
            List(articles) { article in
                NavigationLink {
                    DetailedHelpArticleView(article: article)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Help & Tutorials")
        }
    }
}
