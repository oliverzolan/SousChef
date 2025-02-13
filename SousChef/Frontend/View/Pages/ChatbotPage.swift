import SwiftUI

struct ChatbotPage: View {
    @StateObject private var chatbotController: ChatbotController
    @State private var userInput: String = ""
    @StateObject private var speechRecognitionController = SpeechHelper()
    @EnvironmentObject var userSession: UserSession

    init(userSession: UserSession) {
        _chatbotController = StateObject(wrappedValue: ChatbotController(userSession: userSession))
    }

    var body: some View {
        VStack {
            HeaderComponent(title: "Assistant", onBack: { })

            // Chat log
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 10) {
                        if chatbotController.messages.isEmpty {
                            Text("Say hello to your assistant!")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(chatbotController.messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .onChange(of: chatbotController.messages.count) { oldValue, newValue in
                        if newValue > oldValue, let lastMessage = chatbotController.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))

            // User input, microphone, and send button
            HStack {
                TextField("Type a message...", text: $userInput)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.leading)

                // Microphone Button (Speech-to-Text)
                Button(action: {
                    if speechRecognitionController.recognizedText.isEmpty {
                        speechRecognitionController.startListening()
                    } else {
                        speechRecognitionController.stopListening()
                        userInput = speechRecognitionController.recognizedText
                    }
                }) {
                    Image(systemName: speechRecognitionController.recognizedText.isEmpty ? "mic" : "mic.fill")
                        .font(.system(size: 20))
                        .padding()
                        .background(speechRecognitionController.recognizedText.isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                // Send Button
                Button(action: {
                    chatbotController.sendMessage(userInput)
                    userInput = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.trailing)
                .disabled(userInput.isEmpty || chatbotController.isLoading)
            }
            .padding()
            
            CustomNavigationBar()
        }
        .navigationTitle("Chatbot")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// ChatBubble and Message remain the same
struct ChatBubble: View {
    var message: Message

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .frame(maxWidth: 300, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .frame(maxWidth: 300, alignment: .leading)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// Model for Messages
struct Message: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}

// Preview Struct with Mock Data
struct ChatbotPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockSession = UserSession()
        mockSession.token = "mock_token"

        return ChatbotPage(userSession: mockSession)
            .environmentObject(mockSession)
            .previewDevice("iPhone 16 Pro")
    }
}
