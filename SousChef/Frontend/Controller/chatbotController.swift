import Foundation
import Combine

class ChatbotController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    private var userSession: UserSession

    private let openAIURL = "https://chatgpt.com/g/g-67a98d30ae508191b285c9b263c02ee2-souschef"
    private let apiKey: String
    
    init(userSession: UserSession) {
            self.userSession = userSession
            self.apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAIKey") as? String ?? "Missing API Key"

    }

    // Function to send a message and get ChatGPT's response
    func sendMessage(_ userMessage: String) {
        guard !userMessage.isEmpty else { return }

        let userMessageObject = Message(id: UUID(), text: userMessage, isUser: true)
        messages.append(userMessageObject)

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botMessage = Message(id: UUID(), text: "This is a response to: \"\(userMessage)\"", isUser: false)
            self.messages.append(botMessage)
            self.isLoading = false
        }
    }

    // Function to fetch the response from ChatGPT
    private func fetchChatGPTResponse(for userMessage: String) {
        guard let url = URL(string: openAIURL) else {
            DispatchQueue.main.async {
                self.addErrorMessage("Invalid API URL.")
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // OpenAI API Request Body
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": 200
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.addErrorMessage("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self.addErrorMessage("No data received from ChatGPT.")
                    return
                }

                do {
                    // Decode the response
                    let chatResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let chatGPTMessage = chatResponse.choices.first?.message.content {
                        let botMessage = Message(id: UUID(), text: chatGPTMessage, isUser: false)
                        self.messages.append(botMessage)
                    } else {
                        self.addErrorMessage("No response from ChatGPT.")
                    }
                } catch {
                    self.addErrorMessage("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    // Add an error message to the chat log
    private func addErrorMessage(_ error: String) {
        let errorMessage = Message(id: UUID(), text: error, isUser: false)
        messages.append(errorMessage)
    }
}

// OpenAI API Response Model
struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: ChatMessage
    }

    struct ChatMessage: Codable {
        let role: String
        let content: String
    }
}

