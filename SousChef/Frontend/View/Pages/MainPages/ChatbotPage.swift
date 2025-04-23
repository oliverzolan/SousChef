//
//  ChatbotPage.swift
//  SousChef
//
//  Created by Bennet Rau on 4/3/25.
//

import SwiftUI
import Speech

struct ChatbotPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var chatbotController = ChatbotController()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var userInput: String = ""
    @State private var isTyping: Bool = false
    @Namespace private var bottomID
    var recipeURL: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeader(onNewChat: startNewChat)
                .zIndex(1)

            // Chat content
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                // Empty state
                if chatbotController.messages.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()

                        Image("chef_hat_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 6)

                        Text("Hello, I am SousChef")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.bottom, 2)

                        Text("How can I help you, Chef?")
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.7))

                        Spacer()
                    }
                }

                // Chat log
                ScrollViewReader { proxy in
                    List {
                        ForEach(chatbotController.messages) { message in
                            ChatBubble(message: message)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .background(Color.clear)
                                .padding(.vertical, 2)
                        }

                        if isTyping {
                            ChatBubble(message: Message(text: "...", isUser: false, isTyping: true))
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .background(Color.clear)
                                .padding(.vertical, 2)
                        }

                        // Auto-scroll anchor
                        Color.clear
                            .frame(height: 1)
                            .id(bottomID)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .onChange(of: chatbotController.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 6) {
                HStack {
                    TextField("ASK AI", text: $userInput)
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                // Microphone button
                Button(action: {
                    toggleSpeechRecognition()
                }) {
                    Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(speechRecognizer.isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }

                // Send button
                Button(action: {
                    sendMessage()
                }) {
                    Image("chef_hat_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .disabled(userInput.isEmpty)
            }
            .padding(.top, 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .onAppear {
            if let url = recipeURL, chatbotController.messages.isEmpty {
                let introMessage = """
                Here's a recipe I'm interested in: \(url).
                Can you help me understand it better or suggest similar dishes?
                """
                chatbotController.sendMessage(introMessage)
            }
        }
    }

    // Resets chat state
    private func startNewChat() {
        chatbotController.messages.removeAll()
        userInput = ""
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
    }

    // Sends message to AI
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        chatbotController.sendMessage(userInput)
        userInput = ""
        hideKeyboardWithAnimation()
    }

    private func hideKeyboardWithAnimation() {
        withAnimation(.easeInOut(duration: 0.2)) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
    }
    
    private func toggleSpeechRecognition() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording { transcribedText in
                userInput = transcribedText
            }
        }
    }
}
