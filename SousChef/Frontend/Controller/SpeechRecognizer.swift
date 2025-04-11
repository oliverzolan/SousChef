import Foundation
import Speech
import SwiftUI

class SpeechRecognizer: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    
    private var audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Speech recognition unknown status")
                }
            }
        }
    }
    
    func startRecording(completion: @escaping (String) -> Void) {
        // Check if already recording
        if isRecording {
            stopRecording()
            return
        }
        
        // Reset state
        transcribedText = ""
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        // Configure recognition request
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
            return
        }
        
        // Start recognition task
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopRecording()
                if !self.transcribedText.isEmpty {
                    completion(self.transcribedText)
                }
            }
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        task?.cancel()
        isRecording = false
    }
} 