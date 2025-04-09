import Foundation

class ChatbotController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false

    func sendMessage(_ userMessage: String) {
        let userMsg = Message(text: userMessage, isUser: true)
        messages.append(userMsg)
        isTyping = true

        ChatService.shared.sendMessage(userMessage) { response in
            DispatchQueue.main.async {
                self.isTyping = false
                let botMsg = Message(text: response, isUser: false)
                self.messages.append(botMsg)
            }
        }
    }
}
