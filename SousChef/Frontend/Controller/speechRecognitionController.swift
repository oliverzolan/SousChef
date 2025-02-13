import Foundation
import AVFoundation
import Speech

// A helper for speech-to-text using `SFSpeechRecognizer` and `AVAudioEngine`.
actor SpeechHelper: ObservableObject {
    enum SpeechError: Error {
        case noRecognizerAvailable
        case permissionDenied
        case microphoneRestricted
        case recognizerUnavailable
        
        var description: String {
            switch self {
            case .noRecognizerAvailable: return "Speech recognition is not supported on this device."
            case .permissionDenied: return "Permission to recognize speech was denied."
            case .microphoneRestricted: return "Microphone access is restricted."
            case .recognizerUnavailable: return "Speech recognizer is currently unavailable."
            }
        }
    }
    
    @MainActor @Published var recognizedText: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?

    // Initializes the speech recognizer and requests necessary permissions.
    init() {
        self.speechRecognizer = SFSpeechRecognizer()
        guard speechRecognizer != nil else {
            updateTranscript(with: SpeechError.noRecognizerAvailable)
            return
        }

        Task {
            do {
                guard await SpeechHelper.requestSpeechPermission() else {
                    throw SpeechError.permissionDenied
                }
                guard await SpeechHelper.requestMicrophonePermission() else {
                    throw SpeechError.microphoneRestricted
                }
            } catch {
                updateTranscript(with: error)
            }
        }
    }
    
    @MainActor func startListening() {
        Task {
            await processSpeech()
        }
    }

    @MainActor func stopListening() {
        Task {
            await reset()
        }
    }

    // Begins transcribing speech in real time.
    private func processSpeech() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            updateTranscript(with: SpeechError.recognizerUnavailable)
            return
        }

        do {
            let (engine, request) = try Self.setupAudioEngine()
            self.audioEngine = engine
            self.recognitionRequest = request
            self.recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                self?.handleRecognitionResult(engine: engine, result: result, error: error)
            }
        } catch {
            self.reset()
            updateTranscript(with: error)
        }
    }

    // Stops the speech recognizer and resets components.
    private func reset() {
        recognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }

    // Configures the audio engine for speech input.
    private static func setupAudioEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        
        engine.prepare()
        try engine.start()

        return (engine, request)
    }

    // Processes speech recognition results.
    nonisolated private func handleRecognitionResult(engine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let isFinalResult = result?.isFinal ?? false
        let encounteredError = (error != nil)

        if isFinalResult || encounteredError {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }

        if let result = result {
            updateTranscript(with: result.bestTranscription.formattedString)
        }
    }

    // Updates the transcript text safely in the main thread.
    nonisolated private func updateTranscript(with message: String) {
        Task { @MainActor in
            recognizedText = message
        }
    }

    // Updates the transcript with an error message.
    nonisolated private func updateTranscript(with error: Error) {
        let errorMessage = (error as? SpeechError)?.description ?? error.localizedDescription
        Task { @MainActor in
            recognizedText = "<< \(errorMessage) >>"
        }
    }

    // Requests permission to use the speech recognizer.
    static func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    // Requests microphone access permission.
    static func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
