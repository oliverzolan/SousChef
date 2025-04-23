import Foundation
import SwiftUI

class ChatbotController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false
    
    private var isProcessingMessage = false
    
    func sendMessage(_ userMessage: String) {
        // Prevent multiple simultaneous message processing
        guard !isProcessingMessage else { return }
        
        isProcessingMessage = true
        
        // Add user message to the UI immediately
        let userMsg = Message(text: userMessage, isUser: true)
        DispatchQueue.main.async {
            self.messages.append(userMsg)
            self.isTyping = true
        }
        
        // Send message to AI service
        ChatService.shared.sendMessage(userMessage) { [weak self] response in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTyping = false
                let botMsg = Message(text: response, isUser: false)
                self.messages.append(botMsg)
                self.isProcessingMessage = false
            }
        }
    }
    
    func resetConversation() {
        messages.removeAll()
        isTyping = false
        isProcessingMessage = false
    }
}
