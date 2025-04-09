//
//  ChatService.swift
//  SousChef
//

import Foundation

class ChatService {
    static let shared = ChatService()
    private let apiKey: String
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        if let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIKey") as? String, !key.isEmpty {
            self.apiKey = key
        } else {
            fatalError("Error: OpenAI API Key is missing or empty in Info.plist")
        }
    }

    private var messageHistory: [[String: String]] = []  // Stores previous interactions

    // Customizable system prompt
    private var systemPrompt: String = """
    You are SousChef AI, a professional and upbeat kitchen assistant with deep culinary expertise.
    You:
    - Recommend dishes based on pantry items, cravings, or dietary needs.
    - Offer substitutions, prep guidance, plating tips, and more.
    - Speak like a real chef—confident, enthusiastic, and encouraging.
    - Use culinary terms and phrases like mise en place, umami, and acknoweldge requests with something like: "Yes, Chef!"
    - Can shift tone between beginner-friendly and pro-level.
    - End responses with flair like: 'Let's get cookin'!' or 'Bon appétit!'
    """

    /// Update system prompt dynamically
    func updateSystemPrompt(_ newPrompt: String) {
        self.systemPrompt = newPrompt
    }

    /// Sends a message to the OpenAI API with optional role and tracks history.
    func sendMessage(_ message: String, role: String = "user", completion: @escaping (String) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion("Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // Add current user message to the conversation history
        messageHistory.append(["role": role, "content": message])
        
        // Build the full messages array, always starting with the system prompt
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        messages.append(contentsOf: messageHistory)

        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 600,
            "temperature": 0.85
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion("Error: Failed to encode request JSON.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Network Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion("Error: Invalid response from server.")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 401:
                    completion("Unauthorized: Check your API key.")
                case 429:
                    completion("Rate limit hit. Try again later.")
                default:
                    completion("Server Error: \(httpResponse.statusCode)")
                }
                return
            }

            guard let data = data else {
                completion("Error: Response was empty.")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let reply = decodedResponse.choices.first?.message.content {
                    // Append AI response to message history
                    self.messageHistory.append(["role": "assistant", "content": reply])
                    completion(reply.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion("Error: No reply content found.")
                }
            } catch {
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw API Response:\n\(raw)")
                }
                completion("Error: Failed to parse API response.")
            }
        }
        task.resume()
    }

    /// Clears all stored messages in the session
    func resetConversation() {
        messageHistory.removeAll()
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}
