import SwiftUI

struct HeaderComponent: View {
    var title: String

    var body: some View {
        ZStack {
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 5)
    }
}
