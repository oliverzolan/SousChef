import SwiftUI

struct DetailedHelpArticleView: View {
    let article: HelpArticle
    private let mdOptions = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                let blocks = article.content.components(separatedBy: "\n\n")
                ForEach(blocks, id: \.self) { block in
                    if let md = try? AttributedString(markdown: block, options: mdOptions) {
                        Text(md)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(block)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
