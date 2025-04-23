import SwiftUI

struct ChatBubble: View {
    var message: Message

    var body: some View {
        HStack {
            if message.isUser {
                Spacer() // User messages are right-aligned

                VStack(alignment: .trailing, spacing: 2) {
                    // User Label
                    Text("You")
                        .font(.caption)
                        .foregroundColor(.gray)

                    // User Message Bubble
                    Text(message.text)
                        .padding(12)
                        .background(AppColors.primary2)  // User bubble color
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: 250, alignment: .trailing)
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    // ChefBot Label with Icon
                    HStack(spacing: 4) {
                        Image("chef_hat_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // Smaller chef hat icon
                        Text("ChefBot")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.gray)
                    }

                    // Bot Message Bubble (slightly to the left)
                    Text(message.text)
                        .padding(16)
                        .background(AppColors.secondary2)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true) // allow wrapping on multiple lines
                }
                Spacer() // Leave space on the right
            }
        }
        .padding(.horizontal, 8) // Reduced horizontal padding for a more compact look
        .padding(.vertical, 2)    // Reduced vertical spacing between messages
        .background(Color.clear)  // Clear background for the entire bubble view
    }
}


// MARK: - Preview
struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            ChatBubble(message: Message(text: "Hello! How can I help you today?", isUser: false))
            ChatBubble(message: Message(text: "I need a recipe for spaghetti.", isUser: true))
        }
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
