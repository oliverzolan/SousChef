import SwiftUI

struct HeaderComponent: View {
    var title: String
    var onBack: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                }
            } else {
                Spacer()
                    .frame(width: 40)
            }

            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
                .frame(width: 40)
        }
        .padding(.vertical, 10)
    }
}
