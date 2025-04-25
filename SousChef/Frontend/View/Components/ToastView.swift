import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 80)
                .transition(.opacity)
                .animation(.easeInOut, value: message)
        }
    }
} 